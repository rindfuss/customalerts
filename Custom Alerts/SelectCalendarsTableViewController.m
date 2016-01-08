//
//  SelectCalendarsTableViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 7/8/15.
//  Copyright (c) 2015 Rich Rindfuss. All rights reserved.
//

#import "SelectCalendarsTableViewController.h"

@interface SelectCalendarsTableViewController ()

@end

@implementation SelectCalendarsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
//    return self.calendarIDs.count;
    return self.availableCalendars.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    /*
    cell.textLabel.text = [self.calendarNames objectAtIndex:indexPath.row];
    for (EKCalendar *cal in self.currentCalendars) {
        if ([cal.calendarIdentifier isEqualToString:[self.calendarIDs objectAtIndex:indexPath.row]]) {
            cell.selected = @"Y";
        }
        else {
            cell.selected = @"N";
        }
    } */
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];
    cell.textLabel.text = calendarForRow.title;
    
    BOOL selectedState = [self.currentCalendars containsObject:calendarForRow] ? YES : NO;
    if (selectedState) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];

    if (![self.currentCalendars containsObject:calendarForRow]) {
        [self.currentCalendars addObject:calendarForRow];
        [self updateSelectedCalendarSavedList];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];
    [self.currentCalendars removeObject:calendarForRow];
    [self updateSelectedCalendarSavedList];
    /*
    NSString *selectedString = [self.calendarSelected objectAtIndex:indexPath.row];
    [self.calendarSelected replaceObjectAtIndex:indexPath.row withObject:[selectedString isEqualToString:@"Y"] ? @"N" : @"Y"];
     */
    
}

- (void) updateSelectedCalendarSavedList {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *selectedCalendarIDs = [[NSMutableArray alloc] init];
    for (EKCalendar *calendar in self.currentCalendars) {
        NSString *calendarID = calendar.calendarIdentifier;
        [selectedCalendarIDs addObject:calendarID];
    }
    [defaults setObject:selectedCalendarIDs forKey:@"selected_calendars_preference" ];

}
@end
