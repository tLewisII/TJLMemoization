//
// Created by Terry Lewis II on 3/7/14.
// Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import "TJLMemoizedFunction.h"
#import <objc/runtime.h>

static const void *key = &key;

@interface TJLMemoizedFunction ()
@property(strong, nonatomic) NSInvocation *invocation;
@property(strong, nonatomic) NSMethodSignature *methodSignature;
@property(strong, nonatomic) NSLock *lock;
@end

@implementation TJLMemoizedFunction

- (instancetype)initWithInvocation:(NSInvocation *)invocation methodSignature:(NSMethodSignature *)methodSignature {
    self = [super init];
    if(!self) {
        return nil;
    }

    _invocation = invocation;
    _methodSignature = methodSignature;
    _lock = [NSLock new];    

    return self;
}

- (id)invoke {
    [self.lock lock];
    id result = objc_getAssociatedObject(self, key);
    if(!result) {
        [self.invocation invoke];
        result = [self returnValueForMethodSignature:self.methodSignature withInvocation:self.invocation];
        objc_setAssociatedObject(self, key, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.lock unlock];

        return result;
    }
    else {
        [self.lock unlock];
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