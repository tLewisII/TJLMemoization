//
//  NSObject+Memoization.m
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Memoization.h"
#import "TJLMemoizedFunction.h"

@implementation NSObject (Memoization)
- (id)memoizeSelector:(SEL)selector withArguments:(id)arguments, ... {
    void *key = (void *)((uintptr_t)(__bridge void *)self ^ (uintptr_t)(void *)selector ^ (uintptr_t)arguments);

    id result = objc_getAssociatedObject(self, key);

//    if(!result) {
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = self;
    va_list args;
    va_start(args, arguments);
    NSInteger index = 2;
    for(id argument = arguments; argument != nil; argument = va_arg(args, id)) {
        [invocation setArgument:&argument atIndex:index++];
    }
    [invocation retainArguments];
    va_end(args);

//        [invocation invoke];
//        id value = [self returnValueForMethodSignature:methodSignature withInvocation:invocation];
//        objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        return value;
//    }
//    else {
//        return result;
//    }
    return [[TJLMemoizedFunction alloc] initWithInvocation:invocation methodSignature:methodSignature];
}

@end
