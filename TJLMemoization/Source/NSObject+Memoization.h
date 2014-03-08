//
//  NSObject+Memoization.h
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Memoization)

/**
* Memoizes the given selector with the given arguments, caching the return value on the first call
* and returning this cached value on subsequent calls. Useful for when you need to
* make intensive computations multiple times with the same inputs but don't want
* to actually do the computation multiple times for performance reasons.
*
* @param selector The selector that you want to memoize. Must be declared on the calling object.
* @param args A variadic argument list that corresponds to the arguments for the given selector.
* Arguments must be in the correct order that they would be passed to the selector.
* @return The return value of the given selector with the given arguments. Caches the return
* value and returns the cached value on subsequent calls of the same selector, instance and arguments.
*/
- (id)memoizeSelector:(SEL)selector withArguments:(id)args, ... NS_REQUIRES_NIL_TERMINATION;

@end
