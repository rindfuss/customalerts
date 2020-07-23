//
//  DateCalculator.h
//  FUMCR Photos
//
//  Created by Rich Rindfuss on 4/23/14.
//  Copyright (c) 2014 Rich Rindfuss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateCalculator : NSObject

+ (NSDate *)dateWithoutTime: (NSDate *)givenDate;
+ (NSDate *)dateFromYear: (NSInteger)year fromMonth: (NSInteger)month fromDay:(NSInteger)day;
+ (NSDate *)datetimeFromYear: (NSInteger)year fromMonth: (NSInteger)month fromDay:(NSInteger)day fromHour:(NSInteger)hour fromMinute:(NSInteger)minute fromSecond:(NSInteger)second;
+ (BOOL)date: (NSDate *)givenDate isWithinEarliestDate: (NSDate *)earliestDate toLatestDate: (NSDate *)latestDate;

+ (BOOL)date: (NSDate *)date1 isEarlierThan: (NSDate *)date2;
+ (BOOL)date: (NSDate *)date1 isLaterThan: (NSDate *)date2;
+ (BOOL)date: (NSDate *)date1 isSameAs: (NSDate *)date2;

+ (NSInteger)monthsBetween: (NSDate *)date1 and:(NSDate *)date2;

+ (NSDate *)dateThatIs: (NSInteger)days daysEarlierThan:(NSDate *)givenDate;
+ (NSDate *)dateThatIs: (NSInteger)days daysLaterThan:(NSDate *)givenDate;
+ (NSDate *)dateThatIs: (NSInteger)months monthsEarlierThan:(NSDate *)givenDate;
+ (NSDate *)dateThatIs: (NSInteger)months monthsLaterThan:(NSDate *)givenDate;

+ (NSInteger)yearFor: (NSDate *)date;
+ (NSInteger)monthFor: (NSDate *)date;
+ (NSInteger)dayFor: (NSDate *)date;

+ (NSInteger)hourFor: (NSDate *)date;
+ (NSInteger)minuteFor: (NSDate *)date;
+ (NSInteger)secondFor: (NSDate *)date;

+ (NSString *)monthNameLongForDate: (NSDate *)date;
+ (NSString *)monthNameLongForMonth: (NSInteger)month;
+ (NSString *)monthNameShortForDate: (NSDate *)date;
+ (NSString *)monthNameShortForMonth: (NSInteger)month;

@end
