//
//  NHParameterisedTestCase
//  CocoaUtils
//
//  Created by Nick Hutchinson on 23/05/2013.
//  Copyright (c) 2013 Nick Hutchinson. All rights reserved.
//

#import "NHParameterisedTestCase.h"
#import <objc/runtime.h>

@interface NHParameterisedTestCase ()

@property SenTestRun *testRun;

@property NSDictionary *parameters;

@property NSUInteger testIndex, testCount;

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
    NSUInteger parametersIndex = 0;
    for (NSDictionary *parameters in parameterisedTestData) {
      // So it's easier to identify the set of test data that causes the
      // failure, we generate new methods with '_XofY' appended to the end.
      SEL mangledSelector = NSSelectorFromString([NSString stringWithFormat:
          @"%s_%zuof%zu", sel_getName(testInvocation.selector),
          parametersIndex+1, parameterisedTestData.count]);
      
      Method m = class_getInstanceMethod(self.class, testInvocation.selector);
      class_replaceMethod(self.class, mangledSelector,
                          method_getImplementation(m),
                          method_getTypeEncoding(m));
      
      NSInvocation *parameterisedInvocation = [NSInvocation
            invocationWithMethodSignature:testInvocation.methodSignature];
      parameterisedInvocation.selector = mangledSelector;
      
      NHParameterisedTestCase *test =
          [[self alloc] initWithInvocation:parameterisedInvocation];
      test.parameters = parameters;
      test.testIndex = parametersIndex;
      test.testCount = parameterisedTestData.count;
      [test setValuesForKeysWithDictionary:parameters];
      [testSuite addTest:test];
      
      parametersIndex++;
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
    [SenTestLog testLogWithFormat:@"Test parameters (%zu of %zu) were: %@\n",
     self.testIndex+1, self.testCount, self.parameters];
  }
}

@end
