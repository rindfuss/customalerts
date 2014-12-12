//
//  AlertsViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/20/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "AlertsViewController.h"

@interface AlertsViewController ()

@end

@implementation AlertsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Customize look of buttons
/*
    UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.saveButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.saveButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
*/
    [self configureUserControls];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return self.currentEvent.alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    EKAlarm *alert = [self.currentEvent.alarms objectAtIndex:row];
    
    NSInteger alertQuantity;
    NSInteger alertPeriod;
    
    [self getAlertDateQuantityAndPeriodForAlert:alert onEvent:self.currentEvent usingQuantity:&alertQuantity usingPeriod:&alertPeriod];
    
    NSString *alertPeriodText;
    switch (alertPeriod) {
        case ComponentRowMinutes:
            alertPeriodText = @"minute";
            break;
        case ComponentRowHours:
            alertPeriodText = @"hour";
            break;
        case ComponentRowDays:
            alertPeriodText = @"day";
            break;
        case ComponentRowWeeks:
            alertPeriodText = @"week";
            break;
            
        default:
            alertPeriodText = @"unknown alert period";
            break;
    }
    
    if (alertQuantity != 1) {
        alertPeriodText = [NSString stringWithFormat:@"%@s", alertPeriodText];
    }
    
    NSString *alertText = [NSString stringWithFormat:@"%d %@", alertQuantity, alertPeriodText];
    
    cell.textLabel.text = alertText;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self setAlertPropertiesForSelectionAtIndexPath:indexPath];
    [self initializePicker];
}

#pragma mark - class utility methods
- (void) getAlertDateQuantityAndPeriodForAlert:(EKAlarm *)alert onEvent:(EKEvent *)event usingQuantity:(NSInteger *)alertQuantity usingPeriod:(NSInteger *)alertPeriod {

    NSTimeInterval alertInterval = alert.relativeOffset;
    
    NSDate *eventDate = event.startDate;
    NSDate *alertDate = [NSDate dateWithTimeInterval:alertInterval sinceDate:eventDate];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:alertDate toDate:eventDate options:0];
    
    if (components.minute) {
        *alertPeriod = ComponentRowMinutes;
        *alertQuantity = components.minute + 60*components.hour + 24*60*components.day + 7*24*60*components.week;
    }
    else if (components.hour) {
        *alertPeriod = ComponentRowHours;
        *alertQuantity = components.hour + 24*components.day + 7*24*components.week;
    }
    else if (components.day) {
        *alertPeriod = ComponentRowDays;
        *alertQuantity = components.day + 7*components.week;
    }
    else if (components.week) {
        *alertPeriod = ComponentRowWeeks;
        *alertQuantity = components.week;
    }
    else {
        *alertPeriod = ComponentRowMinutes;
        *alertQuantity = 0;
    }
}


- (void)configureUserControls {

    if (self.currentEvent.alarms.count == 0) {
        [self.alertDetailsPicker setHidden:YES];
        [self.saveButton setHidden:YES];
    }
    else {
        [self.alertDetailsPicker setHidden:NO];
        [self.saveButton setHidden:NO];

        
        if (self.tableView.indexPathForSelectedRow == nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            
        }
        [self setAlertPropertiesForSelectionAtIndexPath:self.tableView.indexPathForSelectedRow];
        [self initializePicker];
    }
}


- (void)setAlertPropertiesForSelectionAtIndexPath:(NSIndexPath *)indexPath {

    self.currentAlert = [self.currentEvent.alarms objectAtIndex: indexPath.row];
    
    NSInteger alertQuantity;
    NSInteger alertPeriod;
    
    [self getAlertDateQuantityAndPeriodForAlert:self.currentAlert onEvent:self.currentEvent usingQuantity:&alertQuantity usingPeriod:&alertPeriod];
    
    self.alertQuantity = alertQuantity;
    self.alertPeriod = alertPeriod;
}

- (void) initializePicker {
    
    [self.alertDetailsPicker selectRow:self.alertQuantity inComponent:ComponentQuantity animated:YES];
    [self.alertDetailsPicker selectRow:self.alertPeriod inComponent:ComponentPeriod animated:YES];
}

- (void)updateAlertSpanning:(EKSpan)span {

    NSInteger quantity = self.alertQuantity;
    NSInteger period = self.alertPeriod;
    
    NSTimeInterval alertInterval = 0;
    
    switch (period) {
        case ComponentRowMinutes:
            alertInterval = -1 * quantity * 60;
            break;
        case ComponentRowHours:
            alertInterval = -1 * quantity * 60 * 60;
            break;
        case ComponentRowDays:
            alertInterval = -1 * quantity * 24 * 60 * 60;
            break;
        case ComponentRowWeeks:
            alertInterval = -1 * quantity * 7 * 24 * 60 * 60;
            break;
            
        default:
            break;
    }
    
    
    [self.currentAlert setRelativeOffset:alertInterval];
    
    NSError *error;
    [self.eventStore saveEvent:self.currentEvent span:span error:&error];
    
    NSIndexPath *currentIndexPath = self.tableView.indexPathForSelectedRow;
    if (currentIndexPath == nil) {
            currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }

    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self configureUserControls];
}


#pragma mark - User Interaction
- (IBAction)editButton:(id)sender {
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.eventStore = self.eventStore;
    eventEditViewController.event = self.currentEvent;
    
    [self presentViewController:eventEditViewController animated:YES completion:nil];
}

- (IBAction)saveButton:(id)sender {
    
    if (self.currentEvent.recurrenceRules == nil) {
        [self updateAlertSpanning:EKSpanThisEvent];
    }
    else {
        if (self.currentEvent.recurrenceRules.count == 0 ) {
            [self updateAlertSpanning:EKSpanThisEvent];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This is a repeating event." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save for this event only", @"Save for future events", nil];
            [actionSheet showInView:self.view];
        }
    }
}


#pragma mark - EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	
	switch (action) {
		case EKEventEditViewActionCanceled:
			// Edit action canceled, do nothing.
			break;
			
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store,
			// and reload table view.
			// If the new event is being added to the default calendar, then update its
			// eventsList.

			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            
            [self.tableView reloadData];

            [self configureUserControls];
            
			break;
			
		case EKEventEditViewActionDeleted:
            // Don't allow deleting
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:nil];
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	
	return  self.eventStore.defaultCalendarForNewEvents;
}


#pragma mark - Picker delegate methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    
    switch (component) {
        case ComponentQuantity:
            title = [NSString stringWithFormat:@"%d", row];
            break;
        case ComponentPeriod:
            switch (row) {
                case ComponentRowMinutes:
                    title = @"Minutes";
                    break;
                case ComponentRowHours:
                    title = @"Hours";
                    break;
                case ComponentRowDays:
                    title = @"Days";
                    break;
                case ComponentRowWeeks:
                    title = @"Weeks";
                    break;
                    
                default:
                    break;
            }
        default:
            break;
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case ComponentQuantity:
            self.alertQuantity = row;
            break;
        case ComponentPeriod:
            self.alertPeriod = row;
            break;
    }
}

#pragma mark - Picker data source methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return ComponentsNum;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger numRows;
    
    switch (component) {
        case ComponentQuantity:
            numRows = ComponentQuantityRows;
            break;
        case ComponentPeriod:
            numRows = ComponentPeriodRows;
            break;
            
        default:
            numRows = 0;
            break;
    }
    
    return numRows;
}

#pragma mark - ActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: // update only current event
            [self updateAlertSpanning:EKSpanThisEvent];
            break;
        case 1: // update future events
            [self updateAlertSpanning:EKSpanFutureEvents];
            break;
            
        default:
            break;
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    
    
}

@end
