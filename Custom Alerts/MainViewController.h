//
//  MainViewController.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/27/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EventsViewController.h"
#import "AppDelegate.h"
#import "CalendarDayButton.h"

#define FirstDayButtonTag 101
#define LastDayButtonTag 142

typedef enum {
    ArrowDirectionLeft = 1,
    ArrowDirectionRight = 2
    } ArrowDirectionType;

//@interface MainViewController : UITableViewController <UITableViewDelegate, EKCalendarChooserDelegate, EKEventEditViewDelegate>
@interface MainViewController : UITableViewController <UITableViewDelegate, EKCalendarChooserDelegate>

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSArray *currentCalendars;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *previousMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMonthButton;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToCalendarEventsButton;
//@property (weak, nonatomic) IBOutlet UIButton *addEventsButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@property (weak, nonatomic) IBOutlet UIView *calendarButtonView;
@property (weak, nonatomic) IBOutlet UIView *calendarHeaderView;

- (IBAction)previousMonthButtonPressed:(id)sender;
- (IBAction)nextMonthButtonPressed:(id)sender;
- (IBAction)calendarsButton:(id)sender;
- (IBAction)todayButton:(id)sender;
//- (IBAction)addEvents:(id)sender; //for testing

- (IBAction)buttonPressed:(id)sender;
- (IBAction)swipeToPreviousMonth:(id)sender;
- (IBAction)swipeToNextMonth:(id)sender;


// Class utility methods

-(void)selectDate:(NSDate *)newDate;
-(void)selectPreviousMonth;
-(void)selectNextMonth;
//-(UIImage *)squareImageFromColor:(UIColor *)color;
-(UIImage *)circleImageFromColor:(UIColor *)color withSize:(CGSize)size;
-(UIImage *)buttonImageWithColor:(UIColor *)color withBrightEdgeColor:(UIColor *)brightEdgeColor withSize:(CGSize)size;
-(UIImage *)arrowButtonImageForDirection:(ArrowDirectionType)arrowDirection withArrowColor:(UIColor *)arrowColor withButtonColor:(UIColor *)buttonColor withBrightEdgeColor:(UIColor *)brightEdgeColor withSize:(CGSize)size;
//-(void)doHighlight:(UIButton*)b;

@end
