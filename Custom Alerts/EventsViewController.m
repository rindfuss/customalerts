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

    [self populateEventsList];
    
    // Set Title
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    self.title = [df stringFromDate:self.selectedDate];
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

        alertsViewController.delegate = self;
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
    
    cell.textLabel.text = event.title;
    
    
    NSString *calendarString = event.calendar.title;
    
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
    if (self.currentCalendars.count > 1) {
        if ([event isAllDay]) {
            eventInfo = [NSString stringWithFormat:@"%@: All Day", calendarString];
        }
        else {
            eventInfo = [NSString stringWithFormat:@"%@: %@-%@", calendarString, startString, endString];
        }
    }
    else {
        if ([event isAllDay]) {
            eventInfo = @"All Day";
        }
        else {
            eventInfo = [NSString stringWithFormat:@"%@-%@", startString, endString];
        }
    }
    cell.detailTextLabel.text = eventInfo;
    
    return cell;
}


#pragma mark - AlertsViewController delegate methods
- (void)alertsViewControllerDidComplete: (AlertsViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - EventsViewController Utility Methods
- (void)populateEventsList {
    
    NSDate *startDate = self.selectedDate;
    NSDate *endDate;
    
    // endDate is 1 day - 1 second = 60*60*24 - 1 seconds = 86400-1 = 86399 seconds from startDate
    endDate = [startDate dateByAddingTimeInterval:86399];
    
    
    // Create the predicate. Pass it the default calendar.
    self.eventsList = [[NSMutableArray alloc] init];
    
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate
                                                                    calendars:self.currentCalendars];
    
    // Fetch all events that match the predicate.
    [self.eventsList addObjectsFromArray:[self.eventStore eventsMatchingPredicate:predicate]];
}

-(BOOL)isDate:(NSDate*)date1 sameDayAsDate:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]==[comp2 day] && [comp1 month]==[comp2 month] && [comp1 year]==[comp2 year];
}
@end
