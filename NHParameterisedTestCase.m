//
//  NHParameterisedTestCase
//  UnitTests
//
//  Created by Nick Hutchinson on 23/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import "NHParameterisedTestCase.h"

@interface NHParameterisedTestCase ()
@property (readwrite) NSDictionary *parameters;
@end

@implementation NHParameterisedTestCase
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  if (self.parameters[key])
    return;  // ignore if the subclass hasn't provided one

  [super setValue:value forUndefinedKey:key];
}

+ (NSArray *)parameterisedTestData {
  return nil;
}

+ (id)defaultTestSuite {
  NSArray *parameterisedTestData = self.parameterisedTestData;
  if (!parameterisedTestData)
    return [super defaultTestSuite];
  
  SenTestSuite *testSuite =
      [[SenTestSuite alloc] initWithName:NSStringFromClass(self.class)];
  
  for (NSInvocation *testInvocation in self.testInvocations) {
    for (NSDictionary *parameters in parameterisedTestData) {
      NHParameterisedTestCase *test =
          [[self alloc] initWithInvocation:testInvocation];
      test.parameters = parameters;
      [test setValuesForKeysWithDictionary:parameters];
      [testSuite addTest:test];
    }
  }
  
  return testSuite;
}

@end




