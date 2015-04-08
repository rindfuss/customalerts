//
//  CAMainViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 4/7/15.
//  Copyright (c) 2015 Rich Rindfuss. All rights reserved.
//

#import "CAMainViewController.h"

@interface CAMainViewController ()

@end

@implementation CAMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentDate = nil;
    [self selectDate:[NSDate date]];
    
    // Set appVersionLabel
    self.appVersionLabel.text = AppVersion;
    
    
    // Make navigation controller panel at top non-transparent so that tableview has appropriate vertical size
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.eventStore = [[EKEventStore alloc] init];
    
    if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL accessGranted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    // display error message here
                }
                else if (!accessGranted)
                {
                    // display access denied error message here
                }
                else
                {
                    // access granted
                    // Get the default calendar from store.
                    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
                    [self loadCurrentCalendars];
                    //[self.goToCalendarEventsButton setEnabled:YES];
                    //                    [self.addEventsButton setEnabled:YES];
                }
            });
        }];
    }
    else
    {
        self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
        [self loadCurrentCalendars];
        //[self.goToCalendarEventsButton setEnabled:YES];
        //        [self.addEventsButton setEnabled:YES];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"eventsEmbedSegue"]) {
        EventsViewController *evc = (EventsViewController *)segue.destinationViewController;
        self.eventsViewController = evc;
    }
    
}


#pragma mark - Class utility methods
- (void)loadCurrentCalendars {
    
    self.currentCalendars = [NSArray arrayWithObject:self.defaultCalendar];
    
    NSMutableArray *savedCalendars = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *selectedCalendarIDs = [defaults objectForKey:@"selected_calendars_preference"];
    for (NSString *calendarID in selectedCalendarIDs) {
        EKCalendar *cal = [self.eventStore calendarWithIdentifier:calendarID];
        if (cal) {
            [savedCalendars addObject:[self.eventStore calendarWithIdentifier:calendarID]];
        }
    }
    self.currentCalendars = savedCalendars;
}

-(void)selectDate:(NSDate *)newDate {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    CalendarDayButton *dayButton;
    
    NSInteger oldMonth;
    NSInteger oldDay;
    NSInteger newMonth;
    NSInteger newDay;
    NSInteger newYear;
    NSDateComponents *newDateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:newDate];
    BOOL isCurrentDateBlank;
    
    if (self.currentDate) {
        isCurrentDateBlank = NO;
        
        NSDate *oldDate = self.currentDate;
        NSDateComponents *oldComponents = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:oldDate];
        oldMonth = [oldComponents month];
        oldDay = [oldComponents day];
    } else {
        isCurrentDateBlank = YES;
    }
    
    newMonth = [newDateComponents month];
    newDay = [newDateComponents day];
    newYear = [newDateComponents year];
    
    // Get tag for first of month button
    // Determine which button will be for the 1st of the month
    NSDateComponents *firstOfMonthComponents = [[NSDateComponents alloc] init];
    [firstOfMonthComponents setDay:1];
    [firstOfMonthComponents setMonth:newMonth];
    [firstOfMonthComponents setYear:[newDateComponents year]];
    NSDate *firstOfMonthDate = [calendar dateFromComponents:firstOfMonthComponents];
    
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:firstOfMonthDate];
    NSInteger firstOfMonthWeekday = [weekdayComponents weekday];  // 1 corresponds to Sunday
    
    NSInteger firstOfMonthButtonTag = firstOfMonthWeekday + FirstDayButtonTag - 1;
    
    
    if (isCurrentDateBlank || (oldMonth != newMonth) ) {
        // Need to update calendar display
        
        
        // Update day buttons
        
        // Determine which button will be for the last of the month
        NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate];
        NSInteger lastOfMonthDayNumber = daysRange.length;
        
        NSInteger lastOfMonthButtonTag = firstOfMonthButtonTag + lastOfMonthDayNumber - 1;
        
        
        // Determine last day of prior month for filling in blank buttons at top
        NSDateComponents *firstOfPreviousMonthComponents = [[NSDateComponents alloc] init];
        [firstOfPreviousMonthComponents setDay:1];
        [firstOfPreviousMonthComponents setMonth: newMonth!=1 ? newMonth-1 : 12];
        [firstOfPreviousMonthComponents setYear: newMonth!=1 ? newYear : newYear-1];
        NSDate *firstOfPreviousMonthDate = [calendar dateFromComponents:firstOfPreviousMonthComponents];
        
        NSRange previousMonthDaysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfPreviousMonthDate];
        NSInteger lastOfPreviousMonthDayNumber = previousMonthDaysRange.length;
        
        
        // Configure buttons for days of previous month
        for (NSInteger i=firstOfMonthButtonTag-1; i>=FirstDayButtonTag; i--) {
            dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
            [dayButton customSetHighlighted:NO];
            
            dayButton.day = lastOfPreviousMonthDayNumber - (firstOfMonthButtonTag - i - 1);
            dayButton.month = newMonth==1 ? 12 : newMonth-1;
            dayButton.year = newMonth==1 ? newYear-1 : newYear;
            
            [dayButton setTitle:[NSString stringWithFormat:@"%li", (long)dayButton.day] forState:UIControlStateNormal];
            
            [dayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        // Configure buttons for selected month
        for (NSInteger i=firstOfMonthButtonTag; i<=lastOfMonthButtonTag; i++) {
            dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
            [dayButton customSetHighlighted:NO];
            dayButton.day = i-firstOfMonthButtonTag+1;
            dayButton.month = newMonth;
            dayButton.year = newYear;
            NSString *buttonTitle = [NSString stringWithFormat:@"%li", (long)dayButton.day];
            [dayButton setTitle: buttonTitle forState:UIControlStateNormal];
            
            [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        // Configure buttons for days of next month
        for (NSInteger i=lastOfMonthButtonTag+1; i<= LastDayButtonTag; i++) {
            dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
            [dayButton customSetHighlighted:NO];
            dayButton.day = i - lastOfMonthButtonTag;
            if (newMonth<12) {
                dayButton.month = newMonth+1;
                dayButton.year = newYear;
            }
            else {
                dayButton.month = 1;
                dayButton.year = newYear + 1;
            }
            [dayButton setTitle:[NSString stringWithFormat:@"%li", (long)dayButton.day] forState:UIControlStateNormal];
            [dayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        // Hide last row of buttons if none of them are for selected month
        if (lastOfMonthButtonTag <= LastDayButtonTag-7) {
            // last of month button is on 2nd to last row, so hide last row
            for (NSInteger i=LastDayButtonTag; i>=LastDayButtonTag-6; i--) {
                dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
                [dayButton setHidden:YES];
            }
        }
        else {
            // last of month button is on last row, so unhide last row
            for (NSInteger i=LastDayButtonTag; i>=LastDayButtonTag-6; i--) {
                dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
                [dayButton setHidden:NO];
            }
        }
    }
    // Update selected date display
    if (!isCurrentDateBlank) {
        CalendarDayButton *oldDayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:firstOfMonthButtonTag + oldDay - 1];
        [oldDayButton customSetHighlighted:NO];
    }
    dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:firstOfMonthButtonTag + newDay - 1];
    [dayButton customSetHighlighted:YES];
    //    [self performSelector:@selector(doHighlight:) withObject:dayButton afterDelay:0]; // have to set the highlight this way using afterDelay so that this code runs after selectDate finishes and the button automatically unhighlights itself
    
    
    NSDateFormatter *df;
    
    // Update month label
    df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    [df setDateFormat:@"MMMM yyyy"];
    self.monthLabel.text = [df stringFromDate:newDate];
    
    
    self.currentDate = newDate;
    
    
}

-(void)selectPreviousMonth {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *currentDateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.currentDate];
    
    NSDateComponents *newDateComponents = [[NSDateComponents alloc] init];
    
    NSInteger currentDay, currentMonth, currentYear;
    NSInteger newDay, newMonth, newYear;
    
    currentDay = [currentDateComponents day];
    currentMonth = [currentDateComponents month];
    currentYear = [currentDateComponents year];
    
    
    newMonth = currentMonth -1;
    newDay = currentDay;
    newYear = currentYear;
    if (newMonth == 0) {
        newMonth = 12;
        newYear = currentYear - 1;
    }
    
    [newDateComponents setMonth:newMonth];
    [newDateComponents setYear:newYear];
    [newDateComponents setDay:1];
    
    NSDate *testDate = [calendar dateFromComponents:newDateComponents];
    NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:testDate];
    NSInteger lastOfMonthDayNumber = daysRange.length;
    if (newDay > lastOfMonthDayNumber) {
        newDay = lastOfMonthDayNumber;
    }
    
    [newDateComponents setDay:newDay];
    NSDate *newDate = [calendar dateFromComponents:newDateComponents];
    
    [self selectDate:newDate];
}

-(void)selectNextMonth {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *currentDateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.currentDate];
    
    NSDateComponents *newDateComponents = [[NSDateComponents alloc] init];
    
    NSInteger currentDay, currentMonth, currentYear;
    NSInteger newDay, newMonth, newYear;
    
    currentDay = [currentDateComponents day];
    currentMonth = [currentDateComponents month];
    currentYear = [currentDateComponents year];
    
    
    newMonth = currentMonth + 1;
    newDay = currentDay;
    newYear = currentYear;
    if (newMonth == 13) {
        newMonth = 1;
        newYear = currentYear + 1;
    }
    
    [newDateComponents setMonth:newMonth];
    [newDateComponents setYear:newYear];
    [newDateComponents setDay:1];
    
    NSDate *testDate = [calendar dateFromComponents:newDateComponents];
    NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:testDate];
    NSInteger lastOfMonthDayNumber = daysRange.length;
    if (newDay > lastOfMonthDayNumber) {
        newDay = lastOfMonthDayNumber;
    }
    
    [newDateComponents setDay:newDay];
    NSDate *newDate = [calendar dateFromComponents:newDateComponents];
    
    [self selectDate:newDate];
}


/*
 -(UIImage *)squareImageFromColor:(UIColor *)color {
 CGRect rect = CGRectMake(0, 0, 1, 1);
 UIGraphicsBeginImageContext(rect.size);
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetFillColorWithColor(context, [color CGColor]);
 CGContextFillRect(context, rect);
 UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return img;
 }
 */

-(UIImage *)circleImageFromColor:(UIColor *)color withSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextFillEllipseInRect (context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


-(UIImage *)buttonImageWithColor:(UIColor *)color withBrightEdgeColor:(UIColor *)brightEdgeColor withSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetAlpha(context, 1.0f);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    
    CGContextSetStrokeColorWithColor(context, [brightEdgeColor CGColor]);
    //Set the width of the pen mark
    CGContextSetLineWidth(context, 1.0);
    
    // Draw a line
    //Start at this point
    CGContextMoveToPoint(context, 1, 1);
    
    //Give instructions to the CGContext
    //(move "pen" around the screen)
    CGContextAddLineToPoint(context, size.width-1.0, 1);
    CGContextMoveToPoint(context, size.width-0.0, 1);
    CGContextAddLineToPoint(context, size.width-0.0, size.height-0.0);
    
    
    //Draw it
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


-(UIImage *)arrowButtonImageForDirection:(ArrowDirectionType)arrowDirection withArrowColor:(UIColor *)arrowColor withButtonColor:(UIColor *)buttonColor withBrightEdgeColor:(UIColor *)brightEdgeColor withSize:(CGSize)size {
    
    UIImage *startingImage = [self buttonImageWithColor:buttonColor withBrightEdgeColor:brightEdgeColor withSize:size];
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the UIImage in the image context to get the button background
    CGContextDrawImage(context, rect, startingImage.CGImage);
    
    // Draw the arrow
    switch (arrowDirection) {
        case ArrowDirectionLeft: {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, size.width * 0.35, size.height/2.0);
            CGPathAddLineToPoint(path, NULL, size.width * 0.65, size.height * 0.35);
            CGPathAddLineToPoint(path, NULL, size.width * 0.65, size.height * 0.65);
            CGPathAddLineToPoint(path, NULL, size.width * 0.36, size.height/2.0);
            CGPathCloseSubpath(path);
            
            CGContextSetFillColorWithColor(context, [arrowColor CGColor]);
            CGContextAddPath(context, path);
            CGContextFillPath(context);
            
            break;
        }
            
        case ArrowDirectionRight: {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, size.width * 0.65, size.height/2.0);
            CGPathAddLineToPoint(path, NULL, size.width * 0.35, size.height * 0.35);
            CGPathAddLineToPoint(path, NULL, size.width * 0.35, size.height * 0.65);
            CGPathAddLineToPoint(path, NULL, size.width * 0.65, size.height/2.0);
            CGPathCloseSubpath(path);
            
            CGContextSetFillColorWithColor(context, [arrowColor CGColor]);
            CGContextAddPath(context, path);
            CGContextFillPath(context);
            
            break;
        }
        default:
            break;
    }
    CGContextStrokePath(context);
    
    UIImage *arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return arrowImage;
}

#pragma mark - User interaction methods

- (IBAction)apr6ButtonPressed:(id)sender {
    
    NSDate *newDate = [DateCalculator dateFromYear:2015 fromMonth:4 fromDay:6];
    self.currentDate = newDate;
    
    self.eventsViewController.eventStore = self.eventStore;
    self.eventsViewController.currentCalendars = self.currentCalendars;
    self.eventsViewController.selectedDate = self.currentDate;
    
    [self.eventsViewController refreshDataAndUpdateDisplay];
}

- (IBAction)apr13ButtonPressed:(id)sender {
    NSDate *newDate = [DateCalculator dateFromYear:2015 fromMonth:4 fromDay:13];
    
    self.currentDate = newDate;
    
    self.eventsViewController.eventStore = self.eventStore;
    self.eventsViewController.currentCalendars = self.currentCalendars;
    self.eventsViewController.selectedDate = self.currentDate;
    
    [self.eventsViewController refreshDataAndUpdateDisplay];
}

- (IBAction)calendarsButtonPressed:(id)sender {
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:self.eventStore];
    //    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly eventStore:self.eventStore];
    
    
    calendarChooser.delegate = self;
    calendarChooser.showsCancelButton = YES;
    calendarChooser.showsDoneButton = YES;
    NSSet *preselectedCalendars = [NSSet setWithArray:self.currentCalendars];
    calendarChooser.selectedCalendars = preselectedCalendars;
    
    [self.navigationController pushViewController:calendarChooser animated:YES];

}
@end
