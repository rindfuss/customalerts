//
//  SelectCalendarsTableViewController.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 7/8/15.
//  Copyright (c) 2015 Rich Rindfuss. All rights reserved.
//

#import "SelectCalendarsTableViewController.h"

@interface SelectCalendarsTableViewController ()
-(UIImage *)circleImageFromColor:(UIColor *)color withSize:(CGSize)size;
-(UIImage *)checkmarkImageFromColor:(UIColor *)color withSize:(CGSize)size withHorizontalMargin:(CGFloat)horizontalMargin withVerticalMargin:(CGFloat)verticalMargin withLineWidth: (CGFloat)lineWidth;

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];
    
    UILabel *calendarTitleLabel = [cell viewWithTag:TagTitleUILabel];
    UIImageView *checkmarkImageView = [cell viewWithTag:TagCheckmarkUIImageView];
    UIImageView *calendarColorCircleImageView = [cell viewWithTag:TagCalendarColorCircleUIImageView];
    
    calendarTitleLabel.text = calendarForRow.title;
    calendarTitleLabel.adjustsFontSizeToFitWidth = YES;
    //calendarTitleLabel.minimumScaleFactor = 0.25f;
    
    // make a circle image that fills 80% of the enclosing view.
    UIColor *calendarColor = [UIColor colorWithCGColor:[calendarForRow CGColor]];
    calendarColorCircleImageView.image = [self circleImageFromColor:calendarColor withSize:CGSizeMake(calendarColorCircleImageView.frame.size.width * 0.8, calendarColorCircleImageView.frame.size.height * 0.8)];
    
    BOOL selectedState = [self.currentCalendars containsObject:calendarForRow] ? YES : NO;
    if (selectedState) {
        // make a checkmark image that fills 60% of the enclosing view -- i.e. there should be a 20% margin around each edge
        checkmarkImageView.image = [self checkmarkImageFromColor:[UIColor blackColor] withSize:checkmarkImageView.frame.size withHorizontalMargin:checkmarkImageView.frame.size.width * 0.20f withVerticalMargin:checkmarkImageView.frame.size.height * 0.20f withLineWidth: 2.0];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        checkmarkImageView.image = NULL;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];

    if (![self.currentCalendars containsObject:calendarForRow]) {
        [self.currentCalendars addObject:calendarForRow];
        [self updateSelectedCalendarSavedList];
    }
    [tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendarForRow = [self.availableCalendars objectAtIndex:indexPath.row];
    [self.currentCalendars removeObject:calendarForRow];
    [self updateSelectedCalendarSavedList];
    [tableView reloadData];
    /*
    NSString *selectedString = [self.calendarSelected objectAtIndex:indexPath.row];
    [self.calendarSelected replaceObjectAtIndex:indexPath.row withObject:[selectedString isEqualToString:@"Y"] ? @"N" : @"Y"];
     */
    
}

#pragma mark - Class Utility Methods
- (void) updateSelectedCalendarSavedList {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *selectedCalendarIDs = [[NSMutableArray alloc] init];
    for (EKCalendar *calendar in self.currentCalendars) {
        NSString *calendarID = calendar.calendarIdentifier;
        [selectedCalendarIDs addObject:calendarID];
    }
    [defaults setObject:selectedCalendarIDs forKey:@"selected_calendars_preference" ];

}

-(UIImage *)circleImageFromColor:(UIColor *)color withSize:(CGSize)size {
    
    // set width and height of circle to smaller dimension of the size passed in. This ensures the result is a circle even if a rectangle is passed in the size argument
    CGFloat circleHeight;
    CGFloat circleWidth;
    
    if (size.height < size.width) {
        circleHeight = size.height;
        circleWidth = size.height;
    }
    else {
        circleHeight = size.height;
        circleWidth = size.width;
    }
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextFillEllipseInRect (context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(UIImage *)checkmarkImageFromColor:(UIColor *)color withSize:(CGSize)size withHorizontalMargin:(CGFloat)horizontalMargin withVerticalMargin:(CGFloat)verticalMargin withLineWidth: (CGFloat)lineWidth {

    CGFloat checkmarkWidth = size.width - 2.0f * horizontalMargin;
    CGFloat checkmarkHeight = size.height - 2.0f * verticalMargin;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, lineWidth);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, horizontalMargin, verticalMargin + checkmarkHeight * 0.75f);
    CGPathAddLineToPoint(path, NULL, horizontalMargin + checkmarkWidth / 4.0f, verticalMargin + checkmarkHeight);
    CGPathAddLineToPoint(path, NULL, horizontalMargin + checkmarkWidth, verticalMargin);
    CGContextAddPath(context, path);
    
    /*
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGPathAddRect(path1, &transform, rect);
    CGContextAddPath(context, path1);
    */
    
    CGContextStrokePath(context);
    
    UIImage *checkmarkImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return checkmarkImage;
}

@end
