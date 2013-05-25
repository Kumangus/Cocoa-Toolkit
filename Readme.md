# Cocoa Toolkit
A grab-bag of useful utility code that I've found useful when developing for Mac/iOS.

## NHDisplayLink
An Objective-C wrapper around [`CVDisplayLink()`](http://developer.apple.com/library/mac/#documentation/QuartzCore/Reference/CVDisplayLinkRef/Reference/reference.html). Allows you to specify the dispatch queue on which your render callbacks will be delivered, somewhat like iOS's `CADisplayLink`.

**NB** If you call `-[start]` on a `NHDisplayLink`, you must call `-[stop]` at some point, or you will have a memory leak.

## NHUnit
A few useful extensions for SenTestingKit (aka OCUnit) to aid unit testing. Specifically:

### Parameterised testing
Declare a subclass of `NHParameterisedTestCase` (itself a subclass of `SenTestCase`) and override `+[parameterisedTestData]` to return an `NSArray` of `NSDictionary`s containing test data that makes sense for your tests. `NHParameterisedTestCase` will then instantiate an instance of your subclass for all combinations of your test data and your `-[test...]` methods.

You can retrieve the parameters dictionary using the `self.parameters` property. Better yet, if you declare properties with the same names as your parameters dictionary keys, we'll use KVC to set them automatically.

Thanks goes to [this blog post](http://briancoyner.github.io/blog/2011/09/12/ocunit-parameterized-test-case/) for demonstrating how to achieve parameterised tests with OCUnit.
  
```objc
@interface MyTestCase : NHParameterisedTestCase
@property int fooBar;
@end

@implementation MyTestCase
+ (NSArray *)parameterisedTestData {
  return @[ @{ @"fooBar": @42, @"someKey": @"someValue"} ];
}

- (void)testAllTheThings {
  STAssertEquals(self.fooBar, 42, @"");
  STAssertEqualObjects(self.parameters[@"fooBar"], @42, @"");
  STAssertEqualObjects(self.parameters[@"someKey"], @"someValue", @"");
}
@end
```

### Asynchronous tests
We have support for waiting (with a timeout) for an asynchronous test to complete: use the `NHUAssertCompletesWithTimeout()` macro to poll the current run-loop until either a dispatch group completes, or a timeout expires.

## NHViewController
A smarty-pants NSViewController subclass that automagically inserts itself into the responder chain, as it really ought to do out of the box. Inspired by [this post](http://www.cocoawithlove.com/2008/07/better-integration-for-nsviewcontroller.html) on Cocoa With Love.

Requires OS X 10.8 at this time, because it makes use of `+[NSMapTable weakToWeakObjectsMapTable]`.
