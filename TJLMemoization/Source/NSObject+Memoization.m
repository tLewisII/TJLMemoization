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
@end
