# Cocoa Utilities

## NHDisplayLink
An Objective-C wrapper around [`CVDisplayLink()`](http://developer.apple.com/library/mac/#documentation/QuartzCore/Reference/CVDisplayLinkRef/Reference/reference.html). Allows you to specify the dispatch queue on which your render callbacks will be delivered, somewhat like iOS's `CADisplayLink`.

**NB** You must call `-[stop]` on your `NHDisplayLink` at some point, or you will have a memory leak.

## NHViewController
A smarty-pants NSViewController subclass that automagically inserts itself into the responder chain, as it really ought to do out of the box. Inspired by [this post](http://www.cocoawithlove.com/2008/07/better-integration-for-nsviewcontroller.html) on Cocoa With Love.

Requires OS X 10.8 at this time, because it makes use of `+[NSMapTable weakToWeakObjectsMapTable]`.