//
//  NSObject+Memoization.m
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Memoization.h"

@implementation NSObject (Memoization)
- (id)memoizeSelector:(SEL)selector withArguments:(id)arguments, ... {
    void *key = (void *)((uintptr_t)(__bridge void *)self ^ (uintptr_t)(void *)selector ^ (uintptr_t)arguments);

    id result = objc_getAssociatedObject(self, key);

    if(!result) {
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;

        va_list args;
        va_start(args, arguments);
        NSInteger index = 2;
        for(id argument = arguments; argument != nil; argument = va_arg(args, id)) {
            [invocation setArgument:&argument atIndex:index++];
        }
        va_end(args);

        [invocation invokeWithTarget:self];
        id value = [self returnValueForMethodSignature:methodSignature withInvocation:invocation];
        objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return value;
    }
    else {
        return result;
    }
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
