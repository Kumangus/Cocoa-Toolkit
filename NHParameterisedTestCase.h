//
//  NHParameterisedTestCase
//  CocoaUtils
//
//  Created by Nick Hutchinson on 23/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

/// @class NHParameterisedTestCase
/// Facilitates easier parameterised testing. Declare a subclass and NHParameterisedTestCase
/// will then instantiate an instance of your subclass for all combinations of your test
/// data and your `-[test...]` methods.

@interface NHParameterisedTestCase : SenTestCase

/// Override this in your subclass to return an array of NSDictionarys that containing test data
/// that makes sense for your tests.
+ (NSArray *)parameterisedTestData;

/// the test data dictionary for the current test instance.
@property (readonly) NSDictionary *parameters;

/// The current test run. This is different to the (poorly-named) -[run] method
/// on SenTest, which has side effects.
@property (readonly) SenTestRun *testRun;

@end
