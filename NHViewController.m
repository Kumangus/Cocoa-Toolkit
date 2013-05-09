//
//  NHViewController.m
//  NHViewController
//
//  Created by Nick Hutchinson on 08/05/2013.
//
//

#import "NHViewController.h"
#import <objc/runtime.h>

@interface NHViewController () {
    // See comment in -setView:
    NSUInteger _setViewReentrancyCounter;
}

@end

typedef void (*SetNextResponderIMP)(NSView*, SEL, NSResponder*);
static SetNextResponderIMP g_OriginalSetNextResponderIMP;
static dispatch_once_t s_didPatchNSView_setNextResponder;

@implementation NHViewController

- (void)setView:(NSView *)newView {
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
        NHSetViewControllerForView(currentView, nil);
        [table removeObjectForKey:currentView];
    }
    
    if (newView) {
        NHSetViewControllerForView(newView, self);
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

static NHViewController * NHGetViewControllerForView(NSView * v) {
    return [NHGetViewToViewControllerMap() objectForKey:v];
}

static void NHSetViewControllerForView(NSView *view,
                                       NHViewController *newController) {
    NSViewController *currentController = NHGetViewControllerForView(view);
    
    if (currentController) {
        NSResponder *controllerNextResponder = currentController.nextResponder;
        g_OriginalSetNextResponderIMP(view, @selector(setNextResponder:),
                                      controllerNextResponder);
        currentController.nextResponder = nil;
    }
    
    if (newController) {
        NSResponder *ownNextResponder = view.nextResponder;
        g_OriginalSetNextResponderIMP(view, @selector(setNextResponder:),
                                      newController);
        currentController.nextResponder = ownNextResponder;
    }
}

// Patch NSView -setNextResponder: to first check if it has a
// NHViewController set.
static void NHPatchNSView_setNextResponder(void* unused) {
    SEL selector = @selector(setNextResponder:);
    
    Method m = class_getInstanceMethod([NSView class], selector);
    
    g_OriginalSetNextResponderIMP =
    (SetNextResponderIMP)method_getImplementation(m);
    
    method_setImplementation(m, imp_implementationWithBlock(
        ^(NSView *view, NSResponder *responder) {
            NHViewController *vc = NHGetViewControllerForView(view);
            if (vc) {
                assert(view.nextResponder == vc);
                [vc setNextResponder:responder];
            } else {
                g_OriginalSetNextResponderIMP(view, selector, responder);
            }
        }));
}

@end
