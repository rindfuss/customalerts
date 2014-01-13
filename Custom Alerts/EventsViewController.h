//
//  EventsViewController.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/19/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "AlertsViewController.h"


@interface EventsViewController : UITableViewController <AlertsViewControllerDelegate, EKCalendarChooserDelegate>

@property (nonatomic, weak) EKEventStore *eventStore;
@property (nonatomic, weak) NSArray *currentCalendars;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray *eventsList;

- (void)alertsViewControllerDidComplete: (AlertsViewController *)controller;

- (void)populateEventsList;
-(BOOL)isDate:(NSDate*)date1 sameDayAsDate:(NSDate*)date2;

@end
