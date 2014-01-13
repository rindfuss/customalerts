//
//  MainViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/27/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentDate = nil;
    [self selectDate:[NSDate date]];
     
    // Set appVersionLabel
    self.appVersionLabel.text = AppVersion;
    
    
    // Make navigation controller panel at top non-transparent so that tableview has appropriate vertical size
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Customize look of control buttons
   
    UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.goToCalendarEventsButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.goToCalendarEventsButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
    
    // Customize look of calendar-related buttons
    UIColor *buttonNormalColor = [UIColor colorWithRed:223.0/255.0f green:222.0/255.0f blue:225.0/255.0f alpha:1];
    
    UIImage *highlightedImage = [self imageFromColor:[UIColor blueColor]];
    
    UIButton *normalButton = (UIButton *)[self.calendarButtonView viewWithTag:FirstDayButtonTag];
    CGSize normalButtonSize = normalButton.frame.size;
    UIImage *normalImageActive = [self buttonImageWithColor:buttonNormalColor withBrightEdgeColor:[UIColor whiteColor] withSize:normalButtonSize];
    
    UIButton *rightEdgeButton = (UIButton *)[self.calendarButtonView viewWithTag:FirstDayButtonTag+6];
    CGSize rightEdgeButtonSize = rightEdgeButton.frame.size;
    UIImage *rightEdgeImageActive = [self buttonImageWithColor:buttonNormalColor withBrightEdgeColor:[UIColor whiteColor] withSize:rightEdgeButtonSize];
    
    NSInteger buttonColumn = 1;
    for (NSInteger i=FirstDayButtonTag; i<=LastDayButtonTag; i++) {
        CalendarDayButton *dayButton = (CalendarDayButton *)[self.calendarButtonView viewWithTag:i];
        [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [dayButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
        if (buttonColumn <=6) {
            [dayButton setBackgroundImage:normalImageActive forState:UIControlStateNormal];
        }
        else {
            [dayButton setBackgroundImage:rightEdgeImageActive forState:UIControlStateNormal];
        }
        
        dayButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        dayButton.layer.borderWidth = 0.5f;
        
        if (buttonColumn == 7) {
            buttonColumn = 1;
        }
        else {
            buttonColumn++;
        }
    }
    
    // Customize header and calendar button views
    [self.calendarHeaderView setBackgroundColor:buttonNormalColor];
    
    // Configure previous and next month buttons
    UIImage *previousMonthImage = [self arrowButtonImageForDirection:ArrowDirectionLeft withArrowColor:[UIColor blackColor] withButtonColor:[UIColor clearColor] withBrightEdgeColor:[UIColor clearColor] withSize:self.previousMonthButton.frame.size];
    [self.previousMonthButton setBackgroundImage:previousMonthImage forState:UIControlStateNormal];
    
    UIImage *nextMonthImage = [self arrowButtonImageForDirection:ArrowDirectionRight withArrowColor:[UIColor blackColor] withButtonColor:[UIColor clearColor] withBrightEdgeColor:[UIColor clearColor] withSize:self.nextMonthButton.frame.size];
    [self.nextMonthButton setBackgroundImage:nextMonthImage forState:UIControlStateNormal];
    
    
    // Disable buttons until user grants access to calendar items
    [self.goToCalendarEventsButton setEnabled:NO];
    [self.addEventsButton setEnabled:NO];

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
                    self.currentCalendars = [NSArray arrayWithObject:self.defaultCalendar];
                    [self.goToCalendarEventsButton setEnabled:YES];
                    [self.addEventsButton setEnabled:YES];
                }
            });
        }];
    }
    else
    {
        self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
        self.currentCalendars = [NSArray arrayWithObject:self.defaultCalendar];
        [self.goToCalendarEventsButton setEnabled:YES];
        [self.addEventsButton setEnabled:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"GoToEventsSegue"])
    {
        EventsViewController *eventsViewController = segue.destinationViewController;
        eventsViewController.eventStore = self.eventStore;
        eventsViewController.currentCalendars = self.currentCalendars;
        
        // Use components to generate a date without a time from the selected date (should end up with midnight on the selected date)
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self.currentDate];
        
        eventsViewController.selectedDate = [cal dateFromComponents:components] ;
    }
}

#pragma mark - User interaction methods

- (IBAction)previousMonthButtonPressed:(id)sender {

    [self selectPreviousMonth];
}

- (IBAction)nextMonthButtonPressed:(id)sender {

    [self selectNextMonth];
}

- (IBAction)calendarsButton:(id)sender {
//    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:self.eventStore];
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly eventStore:self.eventStore];

    
    calendarChooser.delegate = self;
    calendarChooser.showsCancelButton = YES;
    calendarChooser.showsDoneButton = YES;
    NSSet *preselectedCalendars = [NSSet setWithArray:self.currentCalendars];
    calendarChooser.selectedCalendars = preselectedCalendars;

    [self.navigationController pushViewController:calendarChooser animated:YES];
}

- (IBAction)todayButton:(id)sender {
    
    [self selectDate:[NSDate date]];  //update current date to today
}

- (IBAction)addEvents:(id)sender {  // For testing

    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
	
	// set the addController's event store to the current event store.
	addController.eventStore = self.eventStore;
    
    addController.event = [EKEvent eventWithEventStore:self.eventStore];
    addController.event.startDate = [NSDate date];
    addController.event.endDate = [NSDate dateWithTimeIntervalSinceNow:60*60];
	
	// present EventsAddViewController as a modal view controller
    [self presentViewController:addController animated:YES completion:nil];
	
	addController.editViewDelegate = self;

}

- (IBAction)buttonPressed:(id)sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    CalendarDayButton *button = (CalendarDayButton *)sender;
    
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.currentDate];
    
    [dateComponents setDay:button.day];
    [dateComponents setMonth:button.month];
    [dateComponents setYear:button.year];
    
    NSDate *newDate = [calendar dateFromComponents:dateComponents];

    [self selectDate:newDate];
    
}

- (IBAction)swipeToPreviousMonth:(id)sender {
    
    [self selectPreviousMonth];
}

- (IBAction)swipeToNextMonth:(id)sender {
    
    [self selectNextMonth];
}

#pragma mark - Class utility methods
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


-(UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
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

/*
- (void)doHighlight:(CalendarDayButton*)b {
    [b customSetHighlighted:YES];
}
 */

#pragma mark - TableView delegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return tableView.frame.size.height;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}


#pragma mark - EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
	
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


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	
    EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}

#pragma mark - EventsViewController Delegate Methods
- (void)eventsViewControllerDidComplete: (EventsViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Calendar Chooser delegate methods
- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    self.currentCalendars = [calendarChooser.selectedCalendars allObjects];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
