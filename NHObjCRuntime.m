//
//  NHObjCRuntime.h
//  OSXGLEssentials
//
//  Created by Nick Hutchinson on 15/05/2013.
//
//

#import "NHObjCRuntime.h"

IMP NHObjCReplaceInstanceMethod(Class cl, SEL selector, id newImplementation) {
    Method originalMethod = class_getInstanceMethod(cl, selector);
    NSCParameterAssert(originalMethod);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    
    class_replaceMethod(cl,
                        selector,
                        imp_implementationWithBlock(newImplementation),
                        method_getTypeEncoding(originalMethod));
    
    return originalIMP;
}
