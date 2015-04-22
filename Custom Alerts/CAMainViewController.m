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
    self.currentCalendars = [[NSMutableArray alloc] init];
    
    
    // Make navigation controller panel at top non-transparent so that tableview has appropriate vertical size
    [self.navigationController.navigationBar setTranslucent:NO];

    // Set appVersionLabel
    self.appVersionLabel.text = AppVersion;
    
    // Create and place day select buttons
    UIImage *highlightedImage = [self circleImageFromColor:[UIColor blueColor] withSize:CGSizeMake(kDayButtonWidth, kDayButtonHeight)];

    for (NSInteger r=1; r<=6; r++) {
        for (NSInteger c=1; c<=7; c++) {
            CalendarDayButton *cdb = [[CalendarDayButton alloc] init];
            [self.calendarButtonView addSubview:cdb];
            cdb.frame = CGRectMake(kDayButtonMarginLeft + kDayButtonSpacingHorizontal * (c-1) + kDayButtonWidth * (c-1), self.sunLabel.frame.origin.y + self.sunLabel.frame.size.height + kDayButtonMarginTop + kDayButtonSpacingVertical * (r-1) + kDayButtonHeight * (r-1), kDayButtonWidth, kDayButtonHeight);
            cdb.tag = kDayButtonFirstTag + 7 * (r-1) + (c-1);
            [cdb setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [cdb setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [cdb addTarget:self action:@selector(calendarDayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            cdb.backgroundColor = [UIColor brownColor];
            
            if (r==1) {
                // Align the day of week lables to the center of 1st row of day buttons
                UILabel *dayOfWeekLabel;
                switch (c) {
                    case 1:
                        dayOfWeekLabel = self.sunLabel;
                        break;
                    case 2:
                        dayOfWeekLabel = self.monLabel;
                        break;
                    case 3:
                        dayOfWeekLabel = self.tueLabel;
                        break;
                    case 4:
                        dayOfWeekLabel = self.wedLabel;
                        break;
                    case 5:
                        dayOfWeekLabel = self.thuLabel;
                        break;
                    case 6:
                        dayOfWeekLabel = self.friLabel;
                        break;
                    case 7:
                        dayOfWeekLabel = self.satLabel;
                        break;
                }
                [self.calendarButtonView addConstraint:[NSLayoutConstraint constraintWithItem:dayOfWeekLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:cdb
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0
                                                                              constant:0]];
            }
        }
    }

    // Do setup for using calendar database
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

    // configure display
    [self selectDate:[NSDate date]];
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

#pragma mark - Calendar Chooser delegate methods
- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    
    NSSet *selectedCalendars = [calendarChooser selectedCalendars];
    
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    [self.currentCalendars removeAllObjects];
    [self.currentCalendars addObjectsFromArray:[calendarChooser.selectedCalendars allObjects]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *selectedCalendarIDs = [[NSMutableArray alloc] init];
    for (EKCalendar *calendar in self.currentCalendars) {
        NSString *calendarID = calendar.calendarIdentifier;
        [selectedCalendarIDs addObject:calendarID];
    }
    [defaults setObject:selectedCalendarIDs forKey:@"selected_calendars_preference" ];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self selectDate:self.currentDate];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Class utility methods
- (void)loadCurrentCalendars {
    
    NSMutableArray *savedCalendars = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *selectedCalendarIDs = [defaults objectForKey:@"selected_calendars_preference"];
    for (NSString *calendarID in selectedCalendarIDs) {
        EKCalendar *cal = [self.eventStore calendarWithIdentifier:calendarID];
        if (cal) {
            [savedCalendars addObject:cal];
        }
    }
    
    [self.currentCalendars removeAllObjects];
    
    if (savedCalendars.count == 0) {
        [self.currentCalendars addObject:self.defaultCalendar];
    }
    else {
        self.currentCalendars = savedCalendars;
    }
}

-(void)selectDate:(NSDate *)newDate {
    // configures buttons and display for the given date
    // loads appropriate data into events controller
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    CalendarDayButton *dayButton;
    
    NSInteger oldMonth;
    NSInteger oldDay;
    NSInteger newMonth;
    NSInteger newDay;
    NSInteger newYear;

    BOOL isCurrentDateBlank;
    
    if (self.currentDate) {
        isCurrentDateBlank = NO;
        
        NSDate *oldDate = self.currentDate;
        oldMonth = [DateCalculator monthFor:oldDate];
        oldDay = [DateCalculator dayFor:oldDate];
    } else {
        isCurrentDateBlank = YES;
    }
    
    newMonth = [DateCalculator monthFor:newDate];
    newDay = [DateCalculator dayFor:newDate];
    newYear = [DateCalculator yearFor:newDate];
    
    // Get tag for first of month button
    // Determine which button will be for the 1st of the month
    NSDate *firstOfMonthDate = [DateCalculator dateFromYear:newYear fromMonth:newMonth fromDay:1];
    
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:firstOfMonthDate];
    NSInteger firstOfMonthWeekday = [weekdayComponents weekday];  // 1 corresponds to Sunday
    
    NSInteger firstOfMonthButtonTag = firstOfMonthWeekday + kDayButtonFirstTag - 1;
    
    
    if (isCurrentDateBlank || (oldMonth != newMonth) ) {
        // Need to update calendar display
        
        
        // Update day buttons
        
        // Determine which button will be for the last of the month
        NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate];
        NSInteger lastOfMonthDayNumber = daysRange.length;
        
        NSInteger lastOfMonthButtonTag = firstOfMonthButtonTag + lastOfMonthDayNumber - 1;
        
        
        // Determine last day of prior month for filling in blank buttons at top
        NSDate *firstOfPreviousMonthDate = [DateCalculator dateFromYear:newMonth!=1 ? newYear : newYear-1 fromMonth:newMonth!=1 ? newMonth-1 : 12 fromDay:1];
        
        NSRange previousMonthDaysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfPreviousMonthDate];
        NSInteger lastOfPreviousMonthDayNumber = previousMonthDaysRange.length;
        
        
        // Configure buttons for days of previous month
        for (NSInteger i=firstOfMonthButtonTag-1; i>=kDayButtonFirstTag; i--) {
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
        for (NSInteger i=lastOfMonthButtonTag+1; i<= kDayButtonLastTag; i++) {
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
        
        NSInteger rowsForMonth = lastOfMonthDayNumber + (firstOfMonthButtonTag - kDayButtonFirstTag); // total number of day buttons that have to be displayed (1 for each day of month plus however many are needed to display days from the prior month on the 1st row of the calendar)
        rowsForMonth = ceil(rowsForMonth / 7.0); // important to use 7.0 and not just 7 so calculation happens as doubles rather than integers
        
        // Hide last row(s) of buttons if none of them are for selected month
        if (lastOfMonthButtonTag <= kDayButtonLastTag-7) {
            // last of month button is on 2nd to last row, so hide last row
            for (NSInteger i=kDayButtonLastTag; i>=kDayButtonLastTag-6; i--) {
                dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
                [dayButton setHidden:YES];
            }
        }
        else {
            // last of month button is on last row, so unhide last row
            for (NSInteger i=kDayButtonLastTag; i>=kDayButtonLastTag-6; i--) {
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
    self.navigationItem.title = [df stringFromDate:newDate];
    
    self.currentDate = newDate;
    
    self.eventsViewController.eventStore = self.eventStore;
    self.eventsViewController.currentCalendars = self.currentCalendars;
    self.eventsViewController.selectedDate = self.currentDate;
    
    [self.eventsViewController refreshDataAndUpdateDisplay];
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

- (IBAction)calendarDayButtonPressed:(id)sender {
    
    CalendarDayButton *cdb = (CalendarDayButton *)sender;

    NSDate *newDate = [DateCalculator dateFromYear:cdb.year fromMonth:cdb.month fromDay:cdb.day];
    
    [self selectDate:newDate];
}

- (IBAction)todayButton:(id)sender {
    
    [self selectDate:[NSDate date]];  //update current date to today
}


- (IBAction)calendarsButtonPressed:(id)sender {
    //EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:self.eventStore];
    //    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly eventStore:self.eventStore];
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle: EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars entityType:EKEntityTypeEvent eventStore:self.eventStore];
    
    calendarChooser.delegate = self;
    calendarChooser.showsCancelButton = YES;
    calendarChooser.showsDoneButton = YES;
    NSSet *preselectedCalendars = [NSSet setWithArray:self.currentCalendars];
    calendarChooser.selectedCalendars = preselectedCalendars;
    
    [self.navigationController pushViewController:calendarChooser animated:YES];

}
@end
