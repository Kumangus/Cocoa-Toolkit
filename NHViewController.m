//
//  NHViewController.m
//  NHViewController
//
//  Created by Nick Hutchinson on 08/05/2013.
//
//

#import "NHViewController.h"
#import <objc/runtime.h>

#import "NHViewControllerInternal.h"
#import "NHObjCRuntime.h"

@interface NHViewController () {
    // See comment in -setView:
    NSUInteger _setViewReentrancyCounter;
}

@end

typedef void (*SetNextResponderIMP)(NSView*, SEL, NSResponder*);
static SetNextResponderIMP s_OriginalSetNextResponderIMP;

@implementation NHViewController

- (void)setView:(NSView *)newView {
    static dispatch_once_t s_didPatchNSView_setNextResponder;
    dispatch_once_f(&s_didPatchNSView_setNextResponder, NULL,
                    NHPatchNSView_setNextResponder);
    
    // The default implementation of NSView -view calls back into -setView:
    // if the view isn't already set (see the docs). We need to watch for this
    // so we don't send ourselves into an infinite loop when we call -view.
    if (_setViewReentrancyCounter != 0) {
        return [super setView:newView];
    }
    
    ++_setViewReentrancyCounter;
        
    NSMapTable *table = NHGetViewToViewControllerMap();
    NSView *currentView = self.view;
        
    if (currentView) {
        [currentView nh_setViewController:nil];
        [table removeObjectForKey:currentView];
    }
    
    if (newView) {
        [newView nh_setViewController:self];
        [table setObject:self forKey:newView];
    }
    
    [super setView:newView];
    --_setViewReentrancyCounter;
}

static NSMapTable * NHGetViewToViewControllerMap() {
    static NSMapTable *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMapTable weakToWeakObjectsMapTable];
    });
    
    return table;
}

// Patch NSView -setNextResponder: to first check if it has a
// NHViewController set.
static void NHPatchNSView_setNextResponder(void* unused) {
    SEL selector = @selector(setNextResponder:);

    s_OriginalSetNextResponderIMP
        = (SetNextResponderIMP)NHObjCReplaceInstanceMethod([NSView class],
                                                           selector,
            ^(NSView *view, NSResponder *responder) {
                NHViewController *vc = [view nh_viewController];
                if (vc) {
                    assert(view.nextResponder == vc);
                    [vc setNextResponder:responder];
                } else {
                    s_OriginalSetNextResponderIMP(view, selector, responder);
                }
            });
}

@end


@implementation NSView (NHViewController)

- (NHViewController*)nh_viewController {
    return [NHGetViewToViewControllerMap() objectForKey:self];
}

- (void)nh_setViewController:(NHViewController *)newController {
    NSViewController *currentController = self.nh_viewController;
    
    if (currentController) {
        NSResponder *controllerNextResponder = currentController.nextResponder;
        s_OriginalSetNextResponderIMP(self, @selector(setNextResponder:),
                                      controllerNextResponder);
        currentController.nextResponder = nil;
    }
    
    if (newController) {
        NSResponder *ownNextResponder = self.nextResponder;
        s_OriginalSetNextResponderIMP(self, @selector(setNextResponder:),
                                      newController);
        currentController.nextResponder = ownNextResponder;
    }
}

@end
