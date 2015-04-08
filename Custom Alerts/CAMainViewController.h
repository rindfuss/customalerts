//
//  CAMainViewController.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 4/7/15.
//  Copyright (c) 2015 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EventsViewController.h"
#import "AppDelegate.h"
#import "CalendarDayButton.h"
#import "DateCalculator.h"

#define FirstDayButtonTag 101
#define LastDayButtonTag 142

typedef enum {
    ArrowDirectionLeft = 1,
    ArrowDirectionRight = 2
} ArrowDirectionType;

@interface CAMainViewController : UIViewController <EKCalendarChooserDelegate>

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSArray *currentCalendars;

@property (nonatomic, strong) EventsViewController *eventsViewController;

@property (weak, nonatomic) IBOutlet UIButton *previousMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMonthButton;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
//@property (weak, nonatomic) IBOutlet UIButton *addEventsButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@property (weak, nonatomic) IBOutlet UIView *calendarButtonView;
@property (weak, nonatomic) IBOutlet UIView *calendarHeaderView;

- (IBAction)apr6ButtonPressed:(id)sender;
- (IBAction)apr13ButtonPressed:(id)sender;
- (IBAction)calendarsButtonPressed:(id)sender;
@end
