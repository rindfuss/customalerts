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

#define kDayButtonWidth 44
#define kDayButtonHeight 44
#define kDayButtonMarginTop 3
#define kDayButtonMarginLeft 3
#define kDayButtonSpacingHorizontal 1
#define kDayButtonSpacingVertical 1

#define kDayButtonFirstTag 101
#define kDayButtonLastTag 142

typedef enum {
    ArrowDirectionLeft = 1,
    ArrowDirectionRight = 2
} ArrowDirectionType;

@interface CAMainViewController : UIViewController <EKCalendarChooserDelegate>

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSMutableArray *currentCalendars;

@property (nonatomic, strong) EventsViewController *eventsViewController;

@property (weak, nonatomic) IBOutlet UIButton *previousMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMonthButton;
//@property (weak, nonatomic) IBOutlet UIButton *addEventsButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIView *calendarButtonView;
@property (weak, nonatomic) IBOutlet UIView *calendarHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *sunLabel;
@property (weak, nonatomic) IBOutlet UILabel *monLabel;
@property (weak, nonatomic) IBOutlet UILabel *tueLabel;
@property (weak, nonatomic) IBOutlet UILabel *wedLabel;
@property (weak, nonatomic) IBOutlet UILabel *thuLabel;
@property (weak, nonatomic) IBOutlet UILabel *friLabel;
@property (weak, nonatomic) IBOutlet UILabel *satLabel;

- (IBAction)todayButton:(id)sender;
- (IBAction)calendarsButtonPressed:(id)sender;
@end
