//
//  SelectCalendarsTableViewController.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 7/8/15.
//  Copyright (c) 2015 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

#define TagCheckmarkUIImageView 1
#define TagCalendarColorCircleUIImageView 2
#define TagTitleUILabel 3


@interface SelectCalendarsTableViewController : UITableViewController


/*
@property (strong, nonatomic) NSMutableArray *calendarNames;
@property (strong, nonatomic) NSMutableArray *calendarIDs;
@property (strong, nonatomic) NSMutableArray *calendarSelected;
*/

@property (strong, nonatomic) NSArray *availableCalendars;
@property (weak, nonatomic) NSMutableArray *currentCalendars; // needs to be set by CAMainViewController to point to its property that contains an array of currently displayed EKCalendars

@end
