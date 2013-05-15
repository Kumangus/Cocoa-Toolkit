
#import <Cocoa/Cocoa.h>

@class NHViewController;

@interface NSView (NHViewController)
- (NHViewController *)nh_viewController;
- (void)nh_setViewController:(NHViewController *)vc;
@end
