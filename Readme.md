# Cocoa Utilities
A grab-bag of useful utility code that I've found useful when developing for Mac/iOS.

## NHUnit
A few useful extensions for SenTestingKit (aka OCUnit) to aid unit testing. Specifically:
- Easier parameterised testing. Declare a subclass of `NHParameterisedTestCase` and override `+[testCaseParameters]` to return an array of dicts containing test data that makes sense for your tests. NHParameterisedTestCase will then instantiate an instance of your subclass for the cross product of the test data and your `-[test...]` methods.

  You can retrieve the parameters dictionary using the `self.parameters` property. Better yet, if you declare properties with the same names as your parameters dictionary keys, we'll use KVC to set them automatically.

    ```objective-c
    @interface MyTestCase : NHParameterisedTestCase
    @property int fooBar;
    @end
    
    @implementation MyTestCase
    + (NSArray *)testCaseParameters {
      return @[ @{ @"fooBar": @42, @"someKey": @"someValue"} ];
    }
    
    - (void)testAllTheThings {
      STAssertEquals(self.fooBar, 42, @"");
      STAssertEqualObjects(self.parameters[@"fooBar"], @42, @"");
      STAssertEqualObjects(self.parameters[@"someKey"], @"someValue", @"");
    }
    @end
    ```

- Support for waiting (with a timeout) for an asynchronous test to complete. 
  Use the `NHUAssertCompletesWithTimeout()` macro to poll the current run-loop
  until either a dispatch group completes, or a timeout expires.

## NHDisplayLink
An Objective-C wrapper around [`CVDisplayLink()`](http://developer.apple.com/library/mac/#documentation/QuartzCore/Reference/CVDisplayLinkRef/Reference/reference.html). Allows you to specify the dispatch queue on which your render callbacks will be delivered, somewhat like iOS's `CADisplayLink`.

**NB** You must call `-[stop]` on your `NHDisplayLink` at some point, or you will have a memory leak.

## NHViewController
A smarty-pants NSViewController subclass that automagically inserts itself into the responder chain, as it really ought to do out of the box. Inspired by [this post](http://www.cocoawithlove.com/2008/07/better-integration-for-nsviewcontroller.html) on Cocoa With Love.

Requires OS X 10.8 at this time, because it makes use of `+[NSMapTable weakToWeakObjectsMapTable]`.
