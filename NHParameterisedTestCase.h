//
//  NHParameterisedTestCase
//  CocoaUtils
//
//  Created by Nick Hutchinson on 23/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

/// @class NHParameterisedTestCase
/// Facilitates easier parameterised testing. Declare a subclass and override
/// `+[testCaseParameters]` to return an array of dicts containing test data
/// that makes sense for your tests. NHParameterisedTestCase will then
/// instantiate an instance of your subclass for the cross product of the test
/// data and your `-[test...]` methods.
/// 
/// You can retrieve the parameters dictionary using the `self.parameters`
/// property. Better yet, if you declare properties with the same names as your
/// parameters dictionary keys, we'll use KVC to set them automatically.
/// 
/// Example:
///   @interface MyTestCase : NHParameterisedTestCase
///   @property int fooBar;
///   @end
///
///   @implementation MyTestCase
///   + (NSArray *)testCaseParameters {
///     return @[ @{ @"fooBar": @42, @"someKey": @"someValue"} ];
///   }
///
///   - (void)testAllTheThings {
///     STAssertEquals(self.fooBar, 42, @"");
///     STAssertEqualObjects(self.parameters[@"fooBar"], @42, @"");
///     STAssertEqualObjects(self.parameters[@"someKey"], @"someValue", @"");
///   }
///   @end

@interface NHParameterisedTestCase : SenTestCase

/// Override this to return your test data dictionaries.
+ (NSArray *)parameterisedTestData;

/// Returns the test data dictionary for the current test instance.
@property (readonly) NSDictionary* parameters;

@end
