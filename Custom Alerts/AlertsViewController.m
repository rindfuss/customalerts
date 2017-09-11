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
@property (nonatomic, strong) UIActionSheet *alertSpanActionSheet;
@property (nonatomic, strong) UIActionSheet *saveChangesActionSheetForEdit;
@property (nonatomic, strong) UIActionSheet *saveChangesActionSheetForExit;
@property (nonatomic) BOOL isAddAlertPending; // set to true when an add alert is pending but hasn't happened yet (i.e. user hasn't yet responded to an action sheet for a recurring event asking if alert show go on all future events or just the current one. If the add is pending, it's important not to refresh self.alerts from the saved event, because the pending alert hasn't been added to the event yet

-(void)loadAlertsFromEvent;
@end

@implementation AlertsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize buttons
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButton:)];

    // Initialize properties
    self.locationManager = nil;
    self.alertSpanActionSheet = nil;
    self.saveChangesActionSheetForEdit = nil;
    self.saveChangesActionSheetForExit = nil;
    self.isAddAlertPending = NO;
    self.alerts = [[NSMutableArray alloc] init];
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
    [self initializePickerAndAnimate:NO];
}

#pragma mark - class utility methods
-(void)loadAlertsFromEvent {
// reads alerts from self.currentEvent into this class' properties
    if (!self.isAddAlertPending) {
        // only load alerts if there isn't an add pending (see notes at top where the isAddAlertPending property is declared
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
        
        // Filter out duplicates
        [self removeDuplicateAlerts];
        
        // Sort alers with alert nearest to event coming first
        NSArray *sortedArray;
        sortedArray = [self.alerts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSTimeInterval first = -1 * [(CustomAlert *)a alarmIntervalForCustomAlert];
            NSTimeInterval second = -1 * [(CustomAlert *)b alarmIntervalForCustomAlert];
            
            NSComparisonResult comparisonResult = first < second ? NSOrderedAscending : NSOrderedDescending;
            
            return comparisonResult;
        }];
        
        self.alerts = [NSMutableArray arrayWithArray:sortedArray];\
    }
}

- (void)removeDuplicateAlerts {

    // removes duplicate alerts from self.alerts
    NSMutableArray *removeList = [[NSMutableArray alloc] init];
    
    for (CustomAlert *alert in self.alerts) {
        if (![removeList containsObject:alert]) {
            for (CustomAlert *otherAlert in self.alerts) {
                if([alert isEqual:otherAlert] && alert!=otherAlert ) {
                    // the "content" of the alerts match but they're not pointing to the same object
                    [removeList addObject:otherAlert];
                }
            }
        }
    }

    for (CustomAlert *alertToRemove in removeList) {
        [self.alerts removeObjectIdenticalTo:alertToRemove];
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


- (void)updateEventSpanning:(EKSpan)span {

    NSArray *recurRulesArray = self.currentEvent.recurrenceRules;
    BOOL hasRules = self.currentEvent.hasRecurrenceRules;
    BOOL detached = self.currentEvent.isDetached;

    NSError *error = nil;
    BOOL success = [self.eventStore saveEvent:self.currentEvent span:span commit:YES error:&error];
    //[self.currentEvent refresh];

    recurRulesArray = self.currentEvent.recurrenceRules;
    hasRules = self.currentEvent.hasRecurrenceRules;
    detached = self.currentEvent.isDetached;
    
    NSMutableArray<EKAlarm *> *alarms = [[NSMutableArray alloc] init];
    
    for (CustomAlert *alert in self.alerts) {
        NSTimeInterval alarmInterval = alert.alarmIntervalForCustomAlert;
        //EKAlarm *alarm = [[EKAlarm alloc]init];
//        [alarm setRelativeOffset:alarmInterval];
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:alarmInterval];
        [alarms addObject:alarm];
    }
    
    NSArray *alarmArray = [[NSArray alloc] initWithArray:alarms];
    
    self.currentEvent.alarms = alarmArray;
    
    //NSError *error = nil;
    success = [self.eventStore saveEvent:self.currentEvent span:span error:&error];
    self.isAddAlertPending = NO;
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured while saving. The event may have been deleted in another app. Try selecting the event again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
}

- (void)refreshDataAndUpdateDisplayAndNotifyUserOnFail: (BOOL)shouldNotifyUserOnFail {
    
    BOOL didRefresh = [self.currentEvent refresh];
    
    if (didRefresh) {
        // note: the sequence below is important. Configuring user controls assumes tableview has been loaded with current data
        [self loadAlertsFromEvent];
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

-(void) presentEditController {
    // Request location services (for adding locatin to new events)
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized" message:@"Custom Alerts does not have permission to use location services. This may cause issues if you try to edit an event that has a location associated with it. Please enable location services for Custom Alerts in the Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.eventStore = self.eventStore;
    eventEditViewController.event = self.currentEvent;
    
    [self presentViewController:eventEditViewController animated:YES completion:nil];
}

- (void)saveAlerts {
    
    // Remove duplicate alerts before saving
    [self removeDuplicateAlerts];
    
    if (self.currentEvent.recurrenceRules == nil) {
        [self updateEventSpanning:EKSpanThisEvent];
        [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
    }
    else {
        if (self.currentEvent.recurrenceRules.count == 0 ) {
            [self updateEventSpanning:EKSpanThisEvent];
            [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
        }
        else {
            self.alertSpanActionSheet = [[UIActionSheet alloc] initWithTitle:@"This is a repeating event." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save for this event only", @"Save for future events", nil];
            [self.alertSpanActionSheet showInView:self.view];
        }
    }
}

#pragma mark - User Interaction
- (IBAction)editButton:(id)sender {
    [self presentEditController];
}

- (IBAction)addButton:(id)sender {
    
    self.isAddAlertPending = YES;
    
    CustomAlert *newAlert = [[CustomAlert alloc] init];
    
    [self.alerts addObject:newAlert];
    
    [self saveAlerts];
    [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
}


- (IBAction)saveButton:(id)sender {
    
    [self saveAlerts];
}


#pragma mark - EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	// Dismiss the modal view controller
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (action == EKEventEditViewActionSaved) {
        //view controller has saved any changes to self.currentEvent, so re-load alerts from the event
        [self loadAlertsFromEvent];
        [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
    }
    else if (action == EKEventEditViewActionDeleted) {
        [self.navigationController popViewControllerAnimated:NO];
    }
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
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
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
    
    if (actionSheet == self.alertSpanActionSheet) {
        switch (buttonIndex) {
            case 0: { // update only current event
                [self updateEventSpanning:EKSpanThisEvent];
                break;
            }
            case 1: { // update future events
                [self updateEventSpanning:EKSpanFutureEvents];
                break;
            }
            case 2: { // cancel button
                self.isAddAlertPending = NO; // cancel the isAddAlertPending flag in case this alert span action sheet was for adding an alert to a recurring event. If the action sheet was in response to editing an existing alert, it won't hurt anything to clear the isAddAlertPending flag
                // no need to remove the alert that was added to self.alerts when user touched add button, because by not saving it to the event here, as soon as the refresh happens below, self.alerts will be replaced by any alarms from the event
            }
            default: {
                break;
            }
        }
        [self refreshDataAndUpdateDisplayAndNotifyUserOnFail:YES];
    }
    else if (actionSheet == self.saveChangesActionSheetForEdit) {
        switch (buttonIndex) {
            case 0: { // don't save changes
                [self presentEditController];
                break;
            }
            case 1: { // save changes
                [self saveAlerts];
                [self presentEditController];
                break;
            }
        }
    }
    else if (actionSheet == self.saveChangesActionSheetForExit) {
        switch (buttonIndex) {
            case 0: { // don't save changes
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 1: { // save changes
                [self saveAlerts];
                break;
            }
            case 2: { // cancel
                break;
            }
        }
    }
}


@end
