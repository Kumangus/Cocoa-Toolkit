//
//  NHParameterisedTestCase
//  CocoaUtils
//
//  Created by Nick Hutchinson on 23/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import "NHParameterisedTestCase.h"

@interface NHParameterisedTestCase ()

@property NSDictionary *parameters;
@property NSUInteger testIndex;
@property SenTestRun *testRun;

@end

@implementation NHParameterisedTestCase
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  // NSObject's implementation throws an exception by default, but we'll be
  // kind and ignore it for keys the client has defined in the parameters dict
  if (self.parameters[key])
    return;

  [super setValue:value forUndefinedKey:key];
}

+ (NSArray *)parameterisedTestData {
  return nil;
}

+ (id)defaultTestSuite {
  // Fallback to default behaviour if client hasn't overridden
  // +parameterisedTestData. 
  NSArray *parameterisedTestData = self.parameterisedTestData;
  if (!parameterisedTestData)
    return [super defaultTestSuite];
  
  SenTestSuite *testSuite =
      [[SenTestSuite alloc] initWithName:NSStringFromClass(self.class)];
  
  for (NSInvocation *testInvocation in self.testInvocations) {
    NSUInteger idx = 0;
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
      test.testIndex = idx++;
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

- (void)tearDown {
  [super tearDown];

  if (self.parameters && !self.testRun.hasSucceeded) {
    [SenTestLog testLogWithFormat:@"Parameterised test data (#%lu) was: %@\n",
     (unsigned long)self.testIndex, self.parameters];
  }
}

@end
