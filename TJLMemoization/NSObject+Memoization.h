//
//  NSObject+Memoization.h
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Memoization)
- (id)memoizeSelector:(SEL)selector withArguments:(id)args, ...;
@end
