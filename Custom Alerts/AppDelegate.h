//
//  AppDelegate.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/19/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>

// #define AppVersion @"v1.0"
//#define AppVersion @"v1.5.0" // Replaced spinner with monthly calendar view with day buttons to select date
//#define AppVersion @"v2.0" // Updated for iOS 7
//#define AppVersion @"v2.5"
#define AppVersion @"v2.6"
// added ability to remember selected calendars
// added ability to add alerts to events that don't have any
// updated to reflect changes to events made in another app or on another device while Custom Alerts is running
// color-coded events to match color of their calendar
// moved event list to same screen as date selection calendar


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
