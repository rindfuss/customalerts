//
//  CalendarDayButton.h
//  Custom Alerts
//
//  Created by Rich Rindfuss on 11/17/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarDayButton : UIButton

@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;


-(void)setHighlighted:(BOOL)highlighted;
-(void)customSetHighlighted:(BOOL)highlighted;
@end
