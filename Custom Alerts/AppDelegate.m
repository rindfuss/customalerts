//
//  AppDelegate.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/19/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // force top navbar not to use the iOS 15 default transparent background color. In dark mode, the default iOS 15 behavior means black shows through as the navbar background color, and the navbar title disappears, because it's black too
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        navBarAppearance.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 125/255.0 blue: 0.0/255.0 alpha: 1.0];
        [navBarAppearance configureWithOpaqueBackground];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
