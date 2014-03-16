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
#import <libkern/OSAtomic.h>

@implementation NSObject (Memoization)

- (TJLMemoizedFunction *)memoizeSelector:(SEL)selector withArguments:(id)arguments, ... {
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = self;

    va_list args;
    va_start(args, arguments);
    NSInteger index = 2;
    for(id argument = arguments; argument != nil; argument = va_arg(args, id)) {
        [self setArgument:argument atIndex:(NSUInteger)index++ inInvocation:invocation];
    }
    va_end(args);

    [invocation retainArguments];

    return [[TJLMemoizedFunction alloc] initWithInvocation:invocation methodSignature:methodSignature];
}

- (id)memoizeAndInvokeSelector:(SEL)selector withArguments:(id)arguments, ... {
    static OSSpinLock tjlMemoizationLock = OS_SPINLOCK_INIT;

    void *key = (void *)((uintptr_t)(__bridge void *)self ^ (uintptr_t)(void *)selector ^ (uintptr_t)arguments);

    OSSpinLockLock(&tjlMemoizationLock);
    id result = objc_getAssociatedObject(self, key);
    if(!result) {
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;
        invocation.target = self;

        va_list args;
        va_start(args, arguments);
        NSUInteger index = 2;
        for(id argument = arguments; argument != nil; argument = va_arg(args, id)) {
            [self setArgument:argument atIndex:index++ inInvocation:invocation];
        }
        va_end(args);

        [invocation invoke];
        result = [self returnValueForMethodSignature:methodSignature withInvocation:invocation];
        objc_setAssociatedObject(self, key, result, OBJC_ASSOCIATION_RETAIN);
    }

    OSSpinLockUnlock(&tjlMemoizationLock);
    return result;

}

- (void)setArgument:(id)object atIndex:(NSUInteger)index inInvocation:(NSInvocation *)invocation {
#define PULL_AND_SET(type, selector) \
    do { \
        type val = [object selector]; \
        [invocation setArgument:&val atIndex:(NSInteger)index]; \
    } while(0)

    const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if(argType[0] == 'r') {
        argType++;
    }

    if(strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        [invocation setArgument:&object atIndex:(NSInteger)index];
    } else if(strcmp(argType, @encode(char)) == 0) {
        PULL_AND_SET(char, charValue);
    } else if(strcmp(argType, @encode(int)) == 0) {
        PULL_AND_SET(int, intValue);
    } else if(strcmp(argType, @encode(short)) == 0) {
        PULL_AND_SET(short, shortValue);
    } else if(strcmp(argType, @encode(long)) == 0) {
        PULL_AND_SET(long, longValue);
    } else if(strcmp(argType, @encode(long long)) == 0) {
        PULL_AND_SET(long long, longLongValue);
    } else if(strcmp(argType, @encode(unsigned char)) == 0) {
        PULL_AND_SET(unsigned char, unsignedCharValue);
    } else if(strcmp(argType, @encode(unsigned int)) == 0) {
        PULL_AND_SET(unsigned int, unsignedIntValue);
    } else if(strcmp(argType, @encode(unsigned short)) == 0) {
        PULL_AND_SET(unsigned short, unsignedShortValue);
    } else if(strcmp(argType, @encode(unsigned long)) == 0) {
        PULL_AND_SET(unsigned long, unsignedLongValue);
    } else if(strcmp(argType, @encode(unsigned long long)) == 0) {
        PULL_AND_SET(unsigned long long, unsignedLongLongValue);
    } else if(strcmp(argType, @encode(float)) == 0) {
        PULL_AND_SET(float, floatValue);
    } else if(strcmp(argType, @encode(double)) == 0) {
        PULL_AND_SET(double, doubleValue);
    } else if(strcmp(argType, @encode(BOOL)) == 0) {
        PULL_AND_SET(BOOL, boolValue);
    } else if(strcmp(argType, @encode(char *)) == 0) {
        const char *cString = [object UTF8String];
        [invocation setArgument:&cString atIndex:(NSInteger)index];
    } else if(strcmp(argType, @encode(void (^)(void))) == 0) {
        [invocation setArgument:&object atIndex:(NSInteger)index];
    } else {
        NSCParameterAssert([object isKindOfClass:NSValue.class]);

        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment([object objCType], &valueSize, NULL);

#if DEBUG
        NSUInteger argSize = 0;
        NSGetSizeAndAlignment(argType, &argSize, NULL);
        NSCAssert(valueSize == argSize, @"Value size does not match argument size in -setArgument: %@ atIndex: %lu", object, (unsigned long)index);
#endif

        unsigned char valueBytes[valueSize];
        [object getValue:valueBytes];

        [invocation setArgument:valueBytes atIndex:(NSInteger)index];
    }

#undef PULL_AND_SET
}

- (id)returnValueForMethodSignature:(NSMethodSignature *)methodSignature withInvocation:(NSInvocation *)invocation {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[invocation getReturnValue:&val]; \
return @(val); \
} while (0)

    const char *returnType = methodSignature.methodReturnType;
    // Skip const type qualifier.
    if(returnType[0] == 'r') {
        returnType++;
    }

    if(strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0 || strcmp(returnType, @encode(void (^)(void))) == 0) {
        __autoreleasing id returnObj;
        [invocation getReturnValue:&returnObj];
        return returnObj;
    } else if(strcmp(returnType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if(strcmp(returnType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if(strcmp(returnType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if(strcmp(returnType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if(strcmp(returnType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if(strcmp(returnType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if(strcmp(returnType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if(strcmp(returnType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if(strcmp(returnType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if(strcmp(returnType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if(strcmp(returnType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if(strcmp(returnType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if(strcmp(returnType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if(strcmp(returnType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if(strcmp(returnType, @encode(void)) == 0) {
        return nil;
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(returnType, &valueSize, NULL);

        unsigned char valueBytes[valueSize];
        [invocation getReturnValue:valueBytes];

        return [NSValue valueWithBytes:valueBytes objCType:returnType];
    }

#undef WRAP_AND_RETURN

}

@end
