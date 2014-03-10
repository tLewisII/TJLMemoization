//
//  NSObject+Memoization.h
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJLMemoizedFunction;

@interface NSObject (Memoization)

/**
* Memoizes the given selector with the given arguments, caching the return value on the first call
* and returning this cached value on subsequent calls. Useful for when you need to
* make intensive computations multiple times with the same inputs but don't want
* to actually do the computation multiple times for performance reasons.
* Note that this does not actually invoke the selector, but returns a proxy object that can
* be used for calling the selector.
*
* @param selector The selector that you want to memoize. Must be declared on the calling object.
* @param args A variadic argument list that corresponds to the arguments for the given selector.
* Arguments must be in the correct order that they would be passed to the selector. primitive and struct arguments
* must be wrapped in NSNumber or NSValue.
* @return The A TJLMemoizedFunction object the encapsulates the invocation of the given selector
* and return value of the given selector.
*/
- (TJLMemoizedFunction *)memoizeSelector:(SEL)selector withArguments:(id)args, ... NS_REQUIRES_NIL_TERMINATION;

@end
