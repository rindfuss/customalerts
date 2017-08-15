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
    
    // Set appVersionLabel
    self.appVersionLabel.text = AppVersion;
    
    // Make navigation controller panel at top non-transparent so that tableview has appropriate vertical size
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Create placeholder for month label
    self.navigationItem.title = @"";
    
    // set up arrow images for next and previous month buttons
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b1 setFrame:CGRectMake(0.0, 0.0, 47.0, 40.0)];
    [b1 addTarget:self action:@selector(monthButtonPreviousPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *imageMonthPrevious = [self arrowButtonImageForDirection:ArrowDirectionLeft withArrowColor:[UIColor blackColor] withButtonColor:[UIColor clearColor] withBrightEdgeColor:[UIColor clearColor] withSize:b1.frame.size];
    [b1 setImage:imageMonthPrevious forState:UIControlStateNormal];
    UIBarButtonItem *barButtonPrevious = [[UIBarButtonItem alloc] initWithCustomView:b1];
//    UIBarButtonItem *barButtonBlank = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:barButtonBlank, barButtonBlank, barButtonPrevious, nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: barButtonPrevious, nil];
    

    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b2 setFrame:CGRectMake(0.0, 0.0, 47.0, 40.0)];
    [b2 addTarget:self action:@selector(monthButtonNextPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *imageMonthNext = [self arrowButtonImageForDirection:ArrowDirectionRight withArrowColor:[UIColor blackColor] withButtonColor:[UIColor clearColor] withBrightEdgeColor:[UIColor clearColor] withSize:b2.frame.size];
    [b2 setImage:imageMonthNext forState:UIControlStateNormal];
    UIBarButtonItem *barButtonNext = [[UIBarButtonItem alloc] initWithCustomView:b2];
    UIBarButtonItem *barButtonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButtonAdd, barButtonNext, nil];
    

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

            //cdb.backgroundColor = [UIColor brownColor];
            
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need permission to access calendar" message:@"Custom Alerts does not have permission to access your calendar. Please go to the Privacy section of your Settings app, select Calendars, and enable Custom Alerts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    // access granted
                    // Get the default calendar from store.
                    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
                    [self loadCurrentCalendars];

                    BOOL calendarsExist = NO;
                    for (EKCalendar *cal in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
                        if (cal.allowsContentModifications) {
                            calendarsExist = YES;
                            break;
                        }
                    }
                    if (!calendarsExist) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot find any calendars" message:@"Custom Alerts cannot detect any existing calendars. Please close Custom Alerts by double-tapping the home button and swiping up. Open the Calendar app and then re-launch Custom Alerts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                    else {
                        self.eventsViewController.eventStore = self.eventStore;
                        self.eventsViewController.currentCalendars = self.currentCalendars;
                        self.eventsViewController.selectedDate = self.currentDate;
                        
                        [self.eventsViewController refreshDataAndUpdateDisplay];
                    }
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
    
    // Do setup for location services (used if user selects to edit an existing event)
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized" message:@"Custom Alerts does not have permission to use location services. This may generate an error if you try to edit an existing event. Please enable location services for Custom Alerts in the Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case kCLAuthorizationStatusNotDetermined: {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            // all is good
            break;
        }
    }
        
}

- (void)viewWillAppear:(BOOL)animated {

    // The logic below should call the selectDate method with today's date if this is the initial load of the view. If the view is appearing because we've just selected a new set of calendars, for example, from another view controller, the logic below should simply refresh the display (which will take into account any changes to the calendars selected to display)
    
    if (self.currentDate) {
        [self selectDate:self.currentDate];
    }
    else {
        [self selectDate:[NSDate date]];
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
    else if ([segue.identifier isEqualToString:@"calendarsSelectSegue"]) {

        SelectCalendarsTableViewController *vc = (SelectCalendarsTableViewController *)segue.destinationViewController;
        
        // [self.eventStore refreshSourcesIfNecessary]; This line was ineffective at re-populating the eventStore with available calendars if no calendars existed when Custom Alerts was initially launched and then user created an event (and, automatically, a calendar) in the calendar app and then switched back to Custom Alerts. Solution is to swipe closed Custom Alerts and re-launch it. Now that a calendar exists, it and its events will show in Custom Alerts
        
        NSMutableArray *availableCalendars = [[NSMutableArray alloc] init];
        for (EKCalendar *cal in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
//          if (cal.allowsContentModifications && !cal.isImmutable) {
            if (cal.allowsContentModifications) {
                [availableCalendars addObject:cal];
            }
        }

        vc.availableCalendars = availableCalendars; // [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
        vc.currentCalendars = self.currentCalendars;
    }
}

/*
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
*/

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    // Overriding EKEventEditViewDelegate method to update event store according to user actions.
    NSError *error = nil;
    EKEvent *thisEvent = controller.event;
    
    switch (action) {
        case EKEventEditViewActionCanceled:
            // Edit action canceled, do nothing.
            break;
            
        case EKEventEditViewActionSaved:
            // When user hit "Done" button, save the newly created event to the event store
            [controller.eventStore saveEvent:controller.event span:EKSpanFutureEvents error:&error];
            break;
            
        case EKEventEditViewActionDeleted:
            // When deleting an event, remove the event from the event store,
            [controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
            break;
            
        default:
            break;
    }
    // Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    // Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
    
    EKCalendar *calendarForEdit = self.defaultCalendar;
    return calendarForEdit;
}

#pragma mark - Class utility methods
- (void)loadCurrentCalendars {
    
    NSMutableArray *savedCalendars = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *selectedCalendarIDs = [defaults objectForKey:@"selected_calendars_preference"];
    for (NSString *calendarID in selectedCalendarIDs) {
        EKCalendar *cal = [self.eventStore calendarWithIdentifier:calendarID];
        if (cal) {
            if (cal.allowsContentModifications && !cal.isImmutable) {
                [savedCalendars addObject:cal];
            }
        }
    }
    
    [self.currentCalendars removeAllObjects];
    
    if (savedCalendars.count == 0) {
        if (self.defaultCalendar) {
            [self.currentCalendars addObject:self.defaultCalendar];
        }
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
    
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstOfMonthDate];
    NSInteger firstOfMonthWeekday = [weekdayComponents weekday];  // 1 corresponds to Sunday
    
    NSInteger firstOfMonthButtonTag = firstOfMonthWeekday + kDayButtonFirstTag - 1;
    
    
    if (isCurrentDateBlank || (oldMonth != newMonth) ) {
        // Need to update calendar display
        
        
        // Update day buttons
        
        // Determine which button will be for the last of the month
        NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:newDate];
        NSInteger lastOfMonthDayNumber = daysRange.length;
        
        NSInteger lastOfMonthButtonTag = firstOfMonthButtonTag + lastOfMonthDayNumber - 1;
        
        
        // Determine last day of prior month for filling in blank buttons at top
        NSDate *firstOfPreviousMonthDate = [DateCalculator dateFromYear:newMonth!=1 ? newYear : newYear-1 fromMonth:newMonth!=1 ? newMonth-1 : 12 fromDay:1];
        
        NSRange previousMonthDaysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:firstOfPreviousMonthDate];
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
        
        // Unhide buttons needed for this month
        for (NSInteger i=kDayButtonFirstTag; i<=kDayButtonFirstTag + 7*rowsForMonth - 1; i++) {
            dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
            [dayButton setHidden:NO];
        }
        // Hide last row(s) of buttons if none of them are for selected month
        for (NSInteger i=kDayButtonFirstTag + 7*rowsForMonth; i<=kDayButtonLastTag; i++) {
            dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
            [dayButton setHidden:YES];
        }
        
        // resize calendar button view
        self.calendarButtonViewConstraintHeight.constant = kDayOfWeekLabelHeight + kDayButtonMarginTop + rowsForMonth*(kDayButtonHeight + kDayButtonSpacingVertical) + kSpacingCalendarAndEvents;
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
    //UILabel *monthTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    //monthTitleLabel.text=[df stringFromDate:newDate];
    //monthTitleLabel.textAlignment = NSTextAlignmentCenter;
    //monthTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    //monthTitleLabel.adjustsFontSizeToFitWidth=NO;
    //self.navigationItem.titleView=monthTitleLabel;
    self.navigationItem.title = [df stringFromDate:newDate];
    
    self.currentDate = newDate;
    
    self.eventsViewController.eventStore = self.eventStore;
    self.eventsViewController.currentCalendars = self.currentCalendars;
    self.eventsViewController.selectedDate = self.currentDate;
    
    [self.eventsViewController refreshDataAndUpdateDisplay];
}

-(void)selectPreviousMonth {

    NSDate *newDate = [DateCalculator dateThatIs:1 monthsLaterThan:self.currentDate];
    [self selectDate:newDate];
}

-(void)selectNextMonth {

    NSDate *newDate = [DateCalculator dateThatIs:1 monthsEarlierThan: self.currentDate];
    [self selectDate:newDate];
}

-(UIImage *)circleImageFromColor:(UIColor *)color withSize:(CGSize)size {

    // set width and height of circle to smaller dimension of the size passed in. This ensures the result is a circle even if a rectangle is passed in the size argument
    CGFloat circleHeight;
    CGFloat circleWidth;
    
    if (size.height < size.width) {
        circleHeight = size.height;
        circleWidth = size.height;
    }
    else {
        circleHeight = size.height;
        circleWidth = size.width;
    }
    
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




-(UIImage *)arrowButtonImageForDirection:(ArrowDirectionType)arrowDirection withArrowColor:(UIColor *)arrowColor withButtonColor:(UIColor *)buttonColor withBrightEdgeColor:(UIColor *)brightEdgeColor withSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
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

- (IBAction)addButtonPressed:(id)sender {

    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    
    // set the addController's event store to the current event store.
    addController.eventStore = self.eventStore;
    
    addController.event = [EKEvent eventWithEventStore:self.eventStore];
    NSDate *today = [NSDate date];
    NSDate *eventDate = [DateCalculator datetimeFromYear:[DateCalculator yearFor:self.currentDate] fromMonth:[DateCalculator monthFor:self.currentDate] fromDay:[DateCalculator dayFor:self.currentDate] fromHour:[DateCalculator hourFor:today] fromMinute:0 fromSecond:0];
    addController.event.startDate = eventDate;
    addController.event.endDate = [NSDate dateWithTimeInterval:60*60 sinceDate:eventDate];
    
    // present EventsAddViewController as a modal view controller
    [self presentViewController:addController animated:YES completion:nil];
    
    addController.editViewDelegate = self;
}

- (IBAction)calendarDayButtonPressed:(id)sender {
    
    CalendarDayButton *cdb = (CalendarDayButton *)sender;
    
    NSDate *newDate = [DateCalculator dateFromYear:cdb.year fromMonth:cdb.month fromDay:cdb.day];
    
    [self selectDate:newDate];
}

- (IBAction)monthButtonPreviousPressed:(id)sender {
    
    NSDate *newDate = [DateCalculator dateThatIs:1 monthsEarlierThan:self.currentDate];
    
    [self selectDate:newDate];
}

- (IBAction)monthButtonNextPressed:(id)sender {
    
    NSDate *newDate = [DateCalculator dateThatIs:1 monthsLaterThan:self.currentDate];
    
    [self selectDate:newDate];
}

- (IBAction)swipeToPreviousMonth:(id)sender {
    
        [self selectPreviousMonth];
}

- (IBAction)swipeToNextMonth:(id)sender {

    [self selectNextMonth];
}

- (IBAction)todayButton:(id)sender {
    
    [self selectDate:[NSDate date]];  //update current date to today
}


@end
