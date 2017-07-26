//
//  AlertsViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/20/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "AlertsViewController.h"

@interface AlertsViewController ()

@property (nonatomic, strong) NSMutableArray<CustomAlert *> *alerts;

@property (nonatomic, strong) UIActionSheet *addAlertRecurrenceActionSheet;

-(void)loadAlertsFromEvent;
@end

@implementation AlertsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize buttons
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButton:)];

    // Initialize properties
    self.alerts = [NSMutableArray alloc];
    [self loadAlertsFromEvent];

    // configure visual controls
    [self configureUserControlsAndAnimate:NO];
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
    NSInteger numAlarms = self.alerts.count;
    return numAlarms;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    CustomAlert *alert = [self.alerts objectAtIndex:row];
    
    BOOL plural = alert.alertQuantity != 1 ? YES : NO;
    
    NSString *alertPeriodText = [CustomAlert alertPeriodDescriptionForPeriod:alert.alertPeriod withTextCase:TextCaseLower isPlural:plural];
    
    NSString *alertText = [NSString stringWithFormat:@"%ld %@", (long)alert.alertQuantity, alertPeriodText];
    
    cell.textLabel.text = alertText;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self initializePickerAndAnimate:YES];
}

#pragma mark - class utility methods
-(void)loadAlertsFromEvent {
// reads alerts from self.currentEvent into this class' properties
    [self.alerts removeAllObjects];
    
    if (self.currentEvent.alarms) {
        if (self.currentEvent.alarms.count != 0) {
            for (EKAlarm *alarm in self.currentEvent.alarms) {
                CustomAlert *alert = [[CustomAlert alloc] init];
                [alert setAlertQuantityAndPeriodUsingAlarm:alarm];
                [self.alerts addObject:alert];
            }
        }
    }
}

- (void)configureUserControlsAndAnimate: (BOOL)shouldAnimate {

    if (self.alerts.count == 0) {
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

        [self initializePickerAndAnimate: shouldAnimate];
    }
}

- (void) initializePickerAndAnimate: (BOOL)shouldAnimate {
    if (self.tableView.indexPathForSelectedRow == nil) {
        [self.alertDetailsPicker selectRow:0 inComponent:ComponentQuantity animated:shouldAnimate];
        [self.alertDetailsPicker selectRow:ComponentRowMinutes inComponent:ComponentPeriod animated:shouldAnimate];
    }
    else {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        CustomAlert *alert = [self.alerts objectAtIndex:indexPath.row];
        
        [self.alertDetailsPicker selectRow:alert.alertQuantity inComponent:ComponentQuantity animated:shouldAnimate];
        
        NSInteger desiredComponentRow = 0;
        switch (alert.alertPeriod) {
            case PeriodTypeMinutes: {
                desiredComponentRow = ComponentRowMinutes;
                break;
            }
            case PeriodTypeHours: {
                desiredComponentRow = ComponentRowHours;
                break;
            }
            case PeriodTypeDays: {
                desiredComponentRow = ComponentRowDays;
                break;
            }
            case PeriodTypeWeeks: {
                desiredComponentRow = ComponentRowWeeks;
                break;
            }
        }
        [self.alertDetailsPicker selectRow:desiredComponentRow inComponent:ComponentPeriod animated:shouldAnimate];
    }
}


- (void)updateAlertSpanning:(EKSpan)span {

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
    
    CustomAlert *newAlert = [[CustomAlert alloc] init];
    
    [self.alerts addObject:newAlert];
    
    [self.tableView reloadData];
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
    
    NSString *title=@"";
    
    switch (component) {
        case ComponentQuantity:
            title = [NSString stringWithFormat:@"%ld", (long)row];
            break;
        case ComponentPeriod: {
            switch (row) {
                case ComponentRowMinutes: {
                    title = [CustomAlert alertPeriodDescriptionForPeriod:PeriodTypeMinutes withTextCase:TextCaseMixed isPlural:YES];
                    break;
                }
                case ComponentRowHours: {
                    title = [CustomAlert alertPeriodDescriptionForPeriod:PeriodTypeHours withTextCase:TextCaseMixed isPlural:YES];;
                    break;
                }
                case ComponentRowDays: {
                    title = [CustomAlert alertPeriodDescriptionForPeriod:PeriodTypeDays withTextCase:TextCaseMixed isPlural:YES];
                    break;
                }
                case ComponentRowWeeks: {
                    title = [CustomAlert alertPeriodDescriptionForPeriod:PeriodTypeWeeks withTextCase:TextCaseMixed isPlural:YES];
                    break;
                }
                    
                default: {
                    break;
                }
            }
        }
        default: {
            break;
        }
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    CustomAlert *alert = nil;
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow);
    if (indexPath != nil) {
        alert = [self.alerts objectAtIndex:indexPath.row];
        
        switch (component) {
            case ComponentQuantity: {
                alert.alertQuantity = row;
                break;
            }
            case ComponentPeriod: {
                switch (row) {
                    case ComponentRowMinutes: {
                        alert.alertPeriod = PeriodTypeMinutes;
                        break;
                    }
                    case ComponentRowHours: {
                        alert.alertPeriod = PeriodTypeHours;
                        break;
                    }
                    case ComponentRowDays: {
                        alert.alertPeriod = PeriodTypeDays;
                        break;
                    }
                    case ComponentRowWeeks: {
                        alert.alertPeriod = PeriodTypeWeeks;
                        break;
                    }
                }
                break;
            }
        }
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
