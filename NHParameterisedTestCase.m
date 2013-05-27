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
@property SenTestRun *testRun;

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
      // Strange things happen if you try to use one NSInvocation for multiple
      // test cases. Probably a bug, but we can work around it by cloning
      // the NSInvocation.
      // See http://briancoyner.github.io/blog/2011/09/12/ocunit-parameterized-test-case/#comment-837283739
      NSInvocation *invocationClone = [NSInvocation
            invocationWithMethodSignature:testInvocation.methodSignature];
      invocationClone.selector = testInvocation.selector;
      
      NHParameterisedTestCase *test =
          [[self alloc] initWithInvocation:invocationClone];
      test.parameters = parameters;
      [test setValuesForKeysWithDictionary:parameters];
      [testSuite addTest:test];
    }
  }
  
  return testSuite;
}

- (void)performTest:(SenTestRun *)aRun {
  self.testRun = aRun;
  [super performTest:aRun];
}



@end
