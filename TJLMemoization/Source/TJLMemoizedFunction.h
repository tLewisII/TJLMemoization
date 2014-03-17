//
// Created by Terry Lewis II on 3/7/14.
// Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TJLMemoizedFunction : NSObject
/**
* Initializes the proxy with an invocation and methodSignature for later invocation. Don't call this method directly,
* call `memoizeSelector:withArguments:` which will give you back a TJLMemoizedFunction object that encapsulates the given
* selector and arguments for later invocation.
*
* @param invocation The invocation the the given selector.
* @param methodSignature The method signature for the given selector.
* @return An object that encapsulates the given invocation, allowing you to invoke the method at a later time.
*/
- (instancetype)initWithInvocation:(NSInvocation *)invocation methodSignature:(NSMethodSignature *)methodSignature;

/**
* Invokes the invocation that the object was initialized with, returning its return value.
* The method is invoked once and its return value cached, and on subsequent calls the cached value is returned.
*
* @return An object that is the return value for the invocation given in the initializer.
*/
- (id)invoke;
@end