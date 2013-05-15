//
//  NHObjCRuntime.h
//  OSXGLEssentials
//
//  Created by Nick Hutchinson on 15/05/2013.
//
//

#pragma once
#include <objc/runtime.h>
#include <sys/cdefs.h>

__BEGIN_DECLS

/**
 * Replaces a method of class `class`; the method must already be implemented
 * by either `class` or one of its superclasses.
 * @param  klass             The class to which the method will be added
 * @param  selector          The selector of the method to add
 * @param  newImplementation A block with an appropriate type signature. See
 *         http://www.friday.com/bbum/2011/03/17/ios-4-3-imp_implementationwithblock/
 * 
 * @return                   The original implementation.
 */
IMP NHObjCReplaceInstanceMethod(Class klass, SEL selector, id impBlock);


__END_DECLS
