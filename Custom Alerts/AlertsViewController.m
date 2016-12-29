//
//  AlertsViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/20/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "AlertsViewController.h"

@interface AlertsViewController ()

@property (nonatomic, strong) UIActionSheet *addAlertRecurrenceActionSheet;
@property (nonatomic, strong) EKAlarm *addedAlarm;
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
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButton:)];
    
    [self configureUserControlsAndAnimate:NO];
}

- (void)viewWillAppear:(BOOL)animated {

    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:app];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:self.eventStore];
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground: (NSNotification *)notification {
    
    // Refresh event in case something was changed in another app
    [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:NO];
}

- (void)eventStoreChanged: (NSNotification *)notification {
    [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
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
    NSInteger numAlarms = self.currentEvent.alarms.count;

    return numAlarms;
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
    
    NSString *alertText = [NSString stringWithFormat:@"%ld %@", (long)alertQuantity, alertPeriodText];
    
    cell.textLabel.text = alertText;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self setAlertPropertiesForSelectionAtIndexPath:indexPath];
    [self initializePickerAndAnimate:YES];
}

#pragma mark - class utility methods
- (void) getAlertDateQuantityAndPeriodForAlert:(EKAlarm *)alert onEvent:(EKEvent *)event usingQuantity:(NSInteger *)alertQuantity usingPeriod:(NSInteger *)alertPeriod {

    NSTimeInterval alertInterval = (NSTimeInterval)-1 * alert.relativeOffset;

/*
    NSDate *eventDate = event.startDate;

    NSDate *alertDate = [NSDate dateWithTimeInterval:alertInterval sinceDate:eventDate];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSCalendarUnitWeekOfYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:alertDate toDate:eventDate options:0];
    
    if (components.minute) {
        *alertPeriod = ComponentRowMinutes;
        *alertQuantity = components.minute + 60*components.hour + 24*60*components.day + 7*24*60*components.weekOfYear;
    }
    else if (components.hour) {
        *alertPeriod = ComponentRowHours;
        *alertQuantity = components.hour + 24*components.day + 7*24*components.weekOfYear;
    }
    else if (components.day) {
        *alertPeriod = ComponentRowDays;
        *alertQuantity = components.day + 7*components.weekOfYear;
    }
    else if (components.weekOfYear) {
        *alertPeriod = ComponentRowWeeks;
        *alertQuantity = components.weekOfYear;
    }
    else {
        *alertPeriod = ComponentRowMinutes;
        *alertQuantity = 0;
    }
 */
    
    *alertPeriod = ComponentRowMinutes;
    *alertQuantity = alertInterval / (NSTimeInterval) 60;
    
    NSInteger alertHours = alertInterval / (NSTimeInterval) 3600;
    NSInteger alertMinutesRemaining = alertInterval / (NSTimeInterval) 60 - (NSTimeInterval)alertHours * (NSTimeInterval)60;
    if (alertHours >= 1 && alertMinutesRemaining < 1) {
        *alertPeriod = ComponentRowHours;
        *alertQuantity = alertHours;
    }
    
    NSInteger alertDays = alertInterval / (NSTimeInterval) 86400;
    alertMinutesRemaining = alertInterval / (NSTimeInterval) 60 - ((NSTimeInterval)alertDays * (NSTimeInterval)24 * (NSTimeInterval)60);
    if (alertDays >= 1 && alertMinutesRemaining < 1) {
        *alertPeriod = ComponentRowDays;
        *alertQuantity = alertDays;
    }
    
    NSInteger alertWeeks = alertInterval / (NSTimeInterval) 604800;
    alertMinutesRemaining = alertInterval / (NSTimeInterval)60 - ((NSTimeInterval)alertWeeks * (NSTimeInterval)7 * (NSTimeInterval)24 * (NSTimeInterval)60);
    if (alertWeeks >= 1 && alertMinutesRemaining < 1) {
        *alertPeriod = ComponentRowWeeks;
        *alertQuantity = alertWeeks;
    }
}


- (void)configureUserControlsAndAnimate: (BOOL)shouldAnimate {

    if (self.currentEvent.alarms.count == 0) {
        [self.alertDetailsPicker setHidden:YES];
        [self.saveButton setHidden:YES];
        self.navigationItem.rightBarButtonItem = self.addButton;
    }
    else {
        [self.alertDetailsPicker setHidden:NO];
        [self.saveButton setHidden:NO];
        self.navigationItem.rightBarButtonItem = self.editButton;
        
        if (self.tableView.indexPathForSelectedRow == nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            
        }
        [self setAlertPropertiesForSelectionAtIndexPath:self.tableView.indexPathForSelectedRow];
        [self initializePickerAndAnimate: shouldAnimate];
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

- (void) initializePickerAndAnimate: (BOOL)shouldAnimate {
    
    [self.alertDetailsPicker selectRow:self.alertQuantity inComponent:ComponentQuantity animated:shouldAnimate];
    [self.alertDetailsPicker selectRow:self.alertPeriod inComponent:ComponentPeriod animated:shouldAnimate];
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
    BOOL returnValue = [self.eventStore saveEvent:self.currentEvent span:span error:&error];
    
    if (returnValue) {
    }
    else {
    }
    
    [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
    
    /*
    NSIndexPath *currentIndexPath = self.tableView.indexPathForSelectedRow;
    if (currentIndexPath == nil) {
            currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }

    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self configureUserControlsAndAnimate:NO];
     */
}

- (void)refreshDataAndUpdateDisplayAndNotifyUserOnFail: (BOOL)shouldNotifyUserOnFail {
    
    BOOL didRefresh = [self.currentEvent refresh];
    
    if (didRefresh) {
        [self.tableView reloadData];
        [self configureUserControlsAndAnimate:NO];
    }
    else {
        // something happened to event, and it is no longer valid
        if (shouldNotifyUserOnFail) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This event is no longer valid. It may have been deleted on another device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - User Interaction
- (IBAction)editButton:(id)sender {
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.eventStore = self.eventStore;
    eventEditViewController.event = self.currentEvent;
    
    [self presentViewController:eventEditViewController animated:YES completion:nil];
}

- (IBAction)addButton:(id)sender {
    
    self.addedAlarm = [EKAlarm alarmWithRelativeOffset:(NSTimeInterval)0];
    [self.currentEvent addAlarm:self.addedAlarm];
    self.currentAlert = [self.currentEvent.alarms objectAtIndex: 0];

    [self saveAlertAndProcessAsAddedAlert:YES];
}


- (IBAction)saveButton:(id)sender {
    
    [self saveAlertAndProcessAsAddedAlert:NO];
}

- (void)saveAlertAndProcessAsAddedAlert: (BOOL)isAddedAlert {
    
    if (self.currentEvent.recurrenceRules == nil) {
        [self updateAlertSpanning:EKSpanThisEvent];
    }
    else {
        if (self.currentEvent.recurrenceRules.count == 0 ) {
            [self updateAlertSpanning:EKSpanThisEvent];
        }
        else {
            // need an action sheet, but need to have different action sheets for an alert that's been edited vs. one that was created with the add button, so that if user hits cancel on an added alert we know we need to delete that alarm from the event vs. if user hits cancel on an edited alert, we don't need to do anything. This conditional code is in the actionSheetCancel code
            if (isAddedAlert) {
                self.addAlertRecurrenceActionSheet = [[UIActionSheet alloc] initWithTitle:@"This is a repeating event." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Create alert for this event only", @"Create for future events too", nil];
                [self.addAlertRecurrenceActionSheet showInView:self.view];
            }
            else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This is a repeating event." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save for this event only", @"Save for future events", nil];
                [actionSheet showInView:self.view];
            }
        }
    }
    
}

#pragma mark - EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:NO];
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
            title = [NSString stringWithFormat:@"%ld", (long)row];
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
    
    if (actionSheet == self.addAlertRecurrenceActionSheet && buttonIndex == actionSheet.cancelButtonIndex) {
        // if we're editing an existing alert, nothing needs to be done, but if user has hit the add button on an event that had no alerts and it's a recurring event, and then the user hit cancel on the action sheet asking whether to update one or all occurrences, then we need to delete the alarm that was added to the event.
        [self.currentEvent removeAlarm:self.addedAlarm];
        self.addAlertRecurrenceActionSheet = nil; // no need to keep this around anymore
        self.addedAlarm = nil; // no need to keep this around anymore
        
    }
    else {
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
}


@end
