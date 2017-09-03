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
#import <CoreLocation/CoreLocation.h>
#import "EventsViewController.h"
#import "AppDelegate.h"
#import "CalendarDayButton.h"
#import "DateCalculator.h"
#import "SelectCalendarsTableViewController.h"

//#define kDayOfWeekLabelHeight 20.0
//#define kDayButtonWidth 44.0
#define kDayButtonHeight 40.0
//#define kDayButtonMarginTop 3.0
//#define kDayButtonMarginLeft 3.0
//#define kDayButtonSpacingHorizontal 1.0
#define kDayButtonSpacingVertical 1.0
#define kSpacingCalendarAndEvents 4.0
//#define kHeightBottomButtons 46.0

#define kDayButtonFirstTag 101
#define kDayButtonLastTag 142

typedef enum {
    ArrowDirectionLeft = 1,
    ArrowDirectionRight = 2
} ArrowDirectionType;

@interface CAMainViewController : UIViewController <EKCalendarChooserDelegate, EKEventEditViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSMutableArray *currentCalendars;

@property (nonatomic, strong) EventsViewController *eventsViewController;
@property (weak, nonatomic) IBOutlet UIView *viewEventsContainer;

@property (strong, nonatomic) IBOutlet UIView *viewDateAndEvents;

@property (weak, nonatomic) UIBarButtonItem *monthButtonPrevious;
@property (weak, nonatomic) UIBarButtonItem *monthButtonNext;
//@property (weak, nonatomic) IBOutlet UIButton *addEventsButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIView *calendarButtonView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarButtonViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarButtonViewConstraintBottom;
//@property (weak, nonatomic) IBOutlet UIView *calendarHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *sunLabel;
@property (weak, nonatomic) IBOutlet UILabel *monLabel;
@property (weak, nonatomic) IBOutlet UILabel *tueLabel;
@property (weak, nonatomic) IBOutlet UILabel *wedLabel;
@property (weak, nonatomic) IBOutlet UILabel *thuLabel;
@property (weak, nonatomic) IBOutlet UILabel *friLabel;
@property (weak, nonatomic) IBOutlet UILabel *satLabel;

- (IBAction)monthButtonPreviousPressed:(id)sender;
- (IBAction)monthButtonNextPressed:(id)sender;
- (IBAction)swipeToPreviousMonth:(id)sender;
- (IBAction)swipeToNextMonth:(id)sender;



- (IBAction)todayButton:(id)sender;

@end
