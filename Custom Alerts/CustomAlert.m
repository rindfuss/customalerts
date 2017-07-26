//
//  CustomAlert.m
//  Custom Alerts
//
//  Created by Richard Rindfuss on 7/25/17.
//  Copyright © 2017 Rich Rindfuss. All rights reserved.
//

#import "CustomAlert.h"

@implementation CustomAlert

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _alertPeriod = PeriodTypeMinutes;
        _alertQuantity = 0;
    }
    
    return self;
}

+(NSString *)alertPeriodDescriptionForPeriod: (enum AlertPeriodType)periodType withTextCase: (enum TextCaseType)textCase isPlural:(BOOL)plural {
    
    NSString *descr;
    
    switch (periodType) {
        case PeriodTypeMinutes: {
            descr = @"Minute";
            break;
        }
        case PeriodTypeHours: {
            descr = @"Hour";
            break;
        }
        case PeriodTypeDays: {
            descr = @"Day";
            break;
        }
        case PeriodTypeWeeks: {
            descr = @"Week";
            break;
        }
    }
    
    if (plural) {
        descr = [NSString stringWithFormat:@"%@s", descr];
    }
            
    switch (textCase) {
        case TextCaseLower: {
            descr = [descr lowercaseString];
            break;
        }
        case TextCaseUpper: {
            descr = [descr uppercaseString];
            break;
        }
        case TextCaseMixed: {
            break;
        }
    }
    
    return descr;
}

-(void) setAlertQuantityAndPeriodUsingAlarm:(EKAlarm *)alarm {
    NSTimeInterval alertInterval = (NSTimeInterval)-1 * alarm.relativeOffset;
    
    self.alertPeriod = PeriodTypeMinutes;
    self.alertQuantity = alertInterval / (NSTimeInterval) 60;
    
    NSInteger alertHours = alertInterval / (NSTimeInterval) 3600;
    NSInteger alertMinutesRemaining = alertInterval / (NSTimeInterval) 60 - (NSTimeInterval)alertHours * (NSTimeInterval)60;
    if (alertHours >= 1 && alertMinutesRemaining < 1) {
        self.alertPeriod = PeriodTypeHours;
        self.alertQuantity = alertHours;
    }
    
    NSInteger alertDays = alertInterval / (NSTimeInterval) 86400;
    alertMinutesRemaining = alertInterval / (NSTimeInterval) 60 - ((NSTimeInterval)alertDays * (NSTimeInterval)24 * (NSTimeInterval)60);
    if (alertDays >= 1 && alertMinutesRemaining < 1) {
        self.alertPeriod = PeriodTypeDays;
        self.alertQuantity = alertDays;
    }
    
    NSInteger alertWeeks = alertInterval / (NSTimeInterval) 604800;
    alertMinutesRemaining = alertInterval / (NSTimeInterval)60 - ((NSTimeInterval)alertWeeks * (NSTimeInterval)7 * (NSTimeInterval)24 * (NSTimeInterval)60);
    if (alertWeeks >= 1 && alertMinutesRemaining < 1) {
        self.alertPeriod = PeriodTypeWeeks;
        self.alertQuantity = alertWeeks;
    }

}


@end
