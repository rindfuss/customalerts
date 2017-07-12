//
//  EventsViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/19/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "EventsViewController.h"

@interface EventsViewController ()

@end

@implementation EventsViewController


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

    // Set Title
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    self.title = [df stringFromDate:self.selectedDate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:app];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:self.eventStore];


    [self refreshDataAndUpdateDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground: (NSNotification *)notification {
    
    [self refreshDataAndUpdateDisplay];
}

- (void)eventStoreChanged: (NSNotification *)notification {
    [self refreshDataAndUpdateDisplay];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"GoToAlertsSegue"])
	{
		AlertsViewController *alertsViewController = segue.destinationViewController;

//        alertsViewController.delegate = self;
        alertsViewController.eventStore = self.eventStore;
        
        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        alertsViewController.currentEvent = [self.eventsList objectAtIndex:row];
 	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.eventsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    
    EKEvent *event = [self.eventsList objectAtIndex:row];
    
    // set colors to match calendar color
    UIColor *eventCalendarColor = [UIColor colorWithCGColor:[event.calendar CGColor]];
    CGFloat r, g, b, a;
    [eventCalendarColor getRed:&r green:&g blue:&b alpha:&a];
    eventCalendarColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5f];
    cell.accessoryView.backgroundColor = eventCalendarColor;
    cell.accessoryView.tintColor = [UIColor blackColor];
    cell.contentView.superview.backgroundColor = eventCalendarColor;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];

    UILabel *disclosureArrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, cell.contentView.frame.size.height)];
    disclosureArrowLabel.text = @">";
    disclosureArrowLabel.textAlignment = NSTextAlignmentRight;
    disclosureArrowLabel.backgroundColor = [UIColor clearColor];
    disclosureArrowLabel.textColor = [UIColor blackColor];
    cell.accessoryView = disclosureArrowLabel;
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    
    
    
    cell.textLabel.text = event.title;
    
    
//    NSString *calendarString = event.calendar.title;
    
    // Create subtitle string like Calendar: Start-End
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSString *startString = [df stringFromDate:event.startDate];
    
    if ([self isDate:event.startDate sameDayAsDate:event.endDate]) {
        [df setDateStyle:NSDateFormatterNoStyle];
    }
    else {
        [df setDateStyle:NSDateFormatterShortStyle];
    }
    NSString *endString = [df stringFromDate:event.endDate];

    NSString *eventInfo;
/*
    if (self.currentCalendars.count > 1) {
        if ([event isAllDay]) {
            eventInfo = [NSString stringWithFormat:@"%@: All Day", calendarString];
        }
        else {
            eventInfo = [NSString stringWithFormat:@"%@: %@-%@", calendarString, startString, endString];
        }
    }
    else {
 */
        if ([event isAllDay]) {
            eventInfo = @"     All Day";
        }
        else {
            eventInfo = [NSString stringWithFormat:@"     %@-%@", startString, endString];
        }
//    }
    cell.detailTextLabel.text = eventInfo;
    
    return cell;
}


/*
#pragma mark - AlertsViewController delegate methods
- (void)alertsViewControllerDidComplete: (AlertsViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];

}
*/

#pragma mark - Utility Methods
- (void)populateEventsList {
    
    [self.eventStore reset];
    
    NSDate *startDate = [DateCalculator datetimeFromYear:[DateCalculator yearFor:self.selectedDate] fromMonth:[DateCalculator monthFor:self.selectedDate] fromDay:[DateCalculator dayFor:self.selectedDate] fromHour:0 fromMinute:0 fromSecond:0];

    NSDate *endDate = [DateCalculator datetimeFromYear:[DateCalculator yearFor:self.selectedDate] fromMonth:[DateCalculator monthFor:self.selectedDate] fromDay:[DateCalculator dayFor:self.selectedDate] fromHour:23 fromMinute:59 fromSecond:59];
    
    // endDate is 1 day - 1 second = 60*60*24 - 1 seconds = 86400-1 = 86399 seconds from startDate
    //endDate = [startDate dateByAddingTimeInterval:86399];
    
    
    // Create the predicate. Pass it the default calendar.
    self.eventsList = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate
                                                                    calendars:self.currentCalendars];
    
    // Fetch all events that match the predicate.
    [self.eventsList addObjectsFromArray:[self.eventStore eventsMatchingPredicate:predicate]];
    
    // Sort the array by start datetime and then by title
    [self.eventsList sortUsingComparator:^NSComparisonResult(id a, id b) {
        EKEvent *firstEvent = (EKEvent *)a;
        NSDate *firstDate = [a startDate];
        NSLog(@"firstDate = %@",firstDate);
        NSString *firstTitle = [a title];
        NSLog(@"firstTitle = %@",firstTitle);
        
        EKEvent *secondEvent = (EKEvent *)b;
        NSDate *secondDate = [b startDate];
        NSLog(@"secondDate = %@",secondDate);
        NSString *secondTitle = [b title];
        NSLog(@"secondTitle = %@",secondTitle);

        NSComparisonResult compareResult = [firstEvent compareStartDateWithEvent:secondEvent];
        if (compareResult == NSOrderedSame) {
            // start date-time is the same, so now sort on title
            compareResult = [firstTitle caseInsensitiveCompare:secondTitle];
        }
        
        return compareResult;
    }];
}


-(BOOL)isDate:(NSDate*)date1 sameDayAsDate:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]==[comp2 day] && [comp1 month]==[comp2 month] && [comp1 year]==[comp2 year];
}

-(void)refreshDataAndUpdateDisplay {
    
    [self populateEventsList];
    [self.tableView reloadData];
}

-(UIImage *)disclosureArrowImageWithColor:(UIColor *)arrowColor withSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the arrow
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, size.width * 0.65, size.height/2.0);
    CGPathAddLineToPoint(path, NULL, size.width * 0.35, size.height * 0.35);
    CGPathAddLineToPoint(path, NULL, size.width * 0.35, size.height * 0.65);
    CGPathAddLineToPoint(path, NULL, size.width * 0.65, size.height/2.0);
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(context, [arrowColor CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    
    CGContextStrokePath(context);
    
    UIImage *arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return arrowImage;
}

@end
