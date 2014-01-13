//
//  CalendarDayButton.m
//  Custom Alerts
//
//  Created by Rich Rindfuss on 11/17/13.
//  Copyright (c) 2013 Rich Rindfuss. All rights reserved.
//

#import "CalendarDayButton.h"

@implementation CalendarDayButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.day = 0;
        self.month = 0;
        self.year = 0;
    }

    
    return self;
}

-(void)setHighlighted:(BOOL)highlighted {
    // overriding the setHighlighted method in this way basically just turns off the automatic button highlighting

    return;
}

-(void)customSetHighlighted:(BOOL)highlighted {
    // This method provides a manual way of highlighting buttons
    
    [super setHighlighted:highlighted];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




@end
