//
// Created by Terry Lewis II on 3/7/14.
// Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TJLMemoizedFunction : NSObject

- (instancetype)initWithInvocation:(NSInvocation *)invocation methodSignature:(NSMethodSignature *)methodSignature;

- (id)invoke;
@end