//
//  TJLAppDelegate.m
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#import "TJLAppDelegate.h"
#import "NSObject+Memoization.h"

@implementation TJLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSError *error;
    NSString *s = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"document" ofType:@"txt"]
                                                  encoding:NSUTF8StringEncoding error:&error];

    NSDate *now = [NSDate date];
    [self memoizeSelector:@selector(linesFromString:) withArguments:s, nil];
    NSLog(@"%f", [now timeIntervalSinceNow]);
    NSDate *then = [NSDate date];
    [self memoizeSelector:@selector(linesFromString:) withArguments:s, nil];
    NSLog(@"%f", [then timeIntervalSinceNow]);

    NSDate *again = [NSDate date];
    [self memoizeSelector:@selector(linesFromString:) withArguments:[NSString stringWithFormat:@"aaaaaaaaa %@", s], nil];
    NSLog(@"%f", [again timeIntervalSinceNow]);

    return YES;

}

- (id)linesFromString:(NSString *)s {
    NSMutableArray *array = [NSMutableArray array];
    [s enumerateSubstringsInRange:NSMakeRange(0, s.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [array addObject:substring];
    }];
    return array;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
