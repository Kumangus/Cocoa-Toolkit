//
//  NHTestingUtilities.m
//  CocoaUtils
//
//  Created by Nick Hutchinson on 25/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import "NHTestingUtilities.h"

@implementation SenTestCase (NHUnit)

- (bool)nhu_waitWithTimeout:(NSTimeInterval)timeout
       usingCompletionGroup:(dispatch_group_t)grp
                     atLine:(int)lineNumber
                     inFile:(NSString *)fileName
                description:(NSString *)description {
  __block bool timerDidFire = false;
  __block bool dispatchGroupWasSignalled = false;
  CFRunLoopRef rl = CFRunLoopGetCurrent();
  
  CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault,
      CFAbsoluteTimeGetCurrent() + timeout, DBL_MAX, 0, 0,
      ^(CFRunLoopTimerRef timer) {
        if (dispatchGroupWasSignalled)
          return;
        
        NSException *e = [NSException failureInFile:fileName
                                             atLine:lineNumber
                                    withDescription:@"Timeout elapsed; %@",
                                                    description];
        [self failWithException:e];
        CFRunLoopStop(rl);
      });
  
  CFRunLoopAddTimer(rl, timer, kCFRunLoopCommonModes);

  dispatch_queue_t q = dispatch_get_global_queue(
      DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_group_notify(grp, q, ^{
    CFRunLoopPerformBlock(rl, kCFRunLoopCommonModes, ^{
      if (timerDidFire)
        return;

      dispatchGroupWasSignalled = true;
      CFRunLoopTimerInvalidate(timer);
      CFRunLoopStop(rl);
    });
    CFRunLoopWakeUp(rl);
  });
  
  CFRunLoopRun();
  
  CFRunLoopTimerInvalidate(timer);
  CFRelease(timer);
  
  return dispatchGroupWasSignalled;
}

@end
