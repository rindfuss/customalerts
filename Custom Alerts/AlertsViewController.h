//
//  AlertsViewController.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 3/20/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
// TESTING
#import "DateCalculator.h"

//TESTING

#define ComponentsNum     2
#define ComponentQuantity 0
#define ComponentPeriod   1

#define ComponentQuantityRows 100

#define ComponentPeriodRows 4
#define ComponentRowMinutes 0
#define ComponentRowHours   1
#define ComponentRowDays    2
#define ComponentRowWeeks   3


@class AlertsViewController;

/*
@protocol AlertsViewControllerDelegate <NSObject>
- (void)alertsViewControllerDidComplete: (AlertsViewController *)controller;
@end
*/
 
@interface AlertsViewController : UIViewController <EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIPickerView *alertDetailsPicker;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
//@property (nonatomic, weak) id <AlertsViewControllerDelegate> delegate;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *currentEvent;
@property (nonatomic, strong) EKAlarm *currentAlert;

@property (nonatomic) NSInteger alertQuantity;
@property (nonatomic) NSInteger alertPeriod;
@property (nonatomic) BOOL isAddedAlert; //TESTING

- (void) getAlertDateQuantityAndPeriodForAlert:(EKAlarm *)alert onEvent:(EKEvent *)event usingQuantity:(NSInteger *)alertQuantity usingPeriod:(NSInteger *)alertPeriod;

- (void)configureUserControlsAndAnimate: (BOOL)shouldAnimate;
- (void)setAlertPropertiesForSelectionAtIndexPath:(NSIndexPath *)indexPath;
- (void)initializePickerAndAnimate: (BOOL)shouldAnimate;
- (void)updateAlertSpanning: (EKSpan)span;

- (IBAction)editButton:(id)sender;
- (IBAction)saveButton:(id)sender;


@end

