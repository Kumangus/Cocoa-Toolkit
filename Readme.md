# NHViewController

A NSViewController subclass that automagically inserts itself into the responder chain, as it really ought to do out of the box. Inspired by [this post](http://www.cocoawithlove.com/2008/07/better-integration-for-nsviewcontroller.html) on Cocoa With Love.

Requires OS X 10.8 at this time, because it makes use of `+[NSMapTable weakToWeakObjectsMapTable]`.