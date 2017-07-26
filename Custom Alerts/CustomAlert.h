//
//  CustomAlert.h
//  Custom Alerts
//
//  Created by Richard Rindfuss on 7/25/17.
//  Copyright © 2017 Rich Rindfuss. All rights reserved.
//

#ifndef CustomAlert_h
#define CustomAlert_h


#endif /* CustomAlert_h */

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


@interface CustomAlert : NSObject

enum AlertPeriodType {
    PeriodTypeMinutes,
    PeriodTypeHours,
    PeriodTypeDays,
    PeriodTypeWeeks
};

enum TextCaseType {
    TextCaseUpper,
    TextCaseLower,
    TextCaseMixed
};


@property (nonatomic) enum AlertPeriodType alertPeriod;
@property (nonatomic) NSInteger alertQuantity; // i.e. how many of the alertPeriod units

+(NSString *)alertPeriodDescriptionForPeriod: (enum AlertPeriodType)periodType withTextCase: (enum TextCaseType)textCase isPlural: (BOOL)plural;

-(NSTimeInterval) alarmIntervalForCustomAlert;
-(void) setAlertQuantityAndPeriodUsingAlarm:(EKAlarm *)alarm;
@end

