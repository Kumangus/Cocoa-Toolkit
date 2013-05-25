//
//  NHTestingUtilities.h
//  CocoaUtils
//
//  Created by Nick Hutchinson on 25/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

/// @brief Polls the current run loop until the given dispatch group completes,
///        or the timeout fires.
/// @return false if the timeout fired before the completion group; true
///         otherwise.
///
/// Use this when testing asynchronous code. If the time limit elapses before
/// you signal completion via the dispatch group, we generate a test failure.
bool NS_FORMAT_FUNCTION(3, 4)
NHUAssertCompletesWithTimeout(NSTimeInterval timeout,
    dispatch_group_t completionDispatchGroup,
    NSString *msg, ...);



#pragma mark Internal

#define NHUAssertCompletesWithTimeout(timeout, completionDispatchGroup, msg, ...) \
  [self nhu_waitWithTimeout:timeout usingCompletionGroup:completionDispatchGroup atLine:__LINE__ inFile:[NSString stringWithUTF8String:__FILE__] description:[NSString stringWithFormat:msg, ##__VA_ARGS__ ]]

@interface SenTestCase (Internal)
- (bool)nhu_waitWithTimeout:(NSTimeInterval)timeout usingCompletionGroup:(dispatch_group_t)grp atLine:(int)line inFile:(NSString*)fileName description:(NSString *)description;
@end
