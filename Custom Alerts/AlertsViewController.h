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

#import "DateCalculator.h"
#import "CustomAlert.h"

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


@interface AlertsViewController : UIViewController <EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIPickerView *alertDetailsPicker;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

// Must set the properties below before loading this view
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *currentEvent;


- (void)configureUserControlsAndAnimate: (BOOL)shouldAnimate;
- (void)initializePickerAndAnimate: (BOOL)shouldAnimate;
- (void)updateEventSpanning: (EKSpan)span;

- (IBAction)editButton:(id)sender;
- (IBAction)saveButton:(id)sender;


@end

