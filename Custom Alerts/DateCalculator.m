//
//  DateCalculator.m
//  FUMCR Photos
//
//  Created by Rich Rindfuss on 4/23/14.
//  Copyright (c) 2014 Rich Rindfuss. All rights reserved.
//

#import "DateCalculator.h"

@implementation DateCalculator

+ (NSDate *)dateWithoutTime: (NSDate *)givenDate {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: givenDate];

    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components];

    return newDate;
}

+ (NSDate *)dateFromYear: (NSInteger)year fromMonth: (NSInteger)month fromDay:(NSInteger)day
{
    NSDate *date = [self datetimeFromYear:year fromMonth:month fromDay:day fromHour:0 fromMinute:0 fromSecond:0];
    
    return date;
}

+ (NSDate *)datetimeFromYear: (NSInteger)year fromMonth: (NSInteger)month fromDay:(NSInteger)day fromHour:(NSInteger)hour fromMinute:(NSInteger)minute fromSecond:(NSInteger)second {
    
    NSDate *datetime = nil;
    
    if (year >0 && month>=1 && month<=12) {
        NSInteger maxDay = 31;
        if (month==2) {
            maxDay = 29;
        }
        if (month==4 || month==6 || month==9 || month==11) {
            maxDay = 30;
        }
        
        if (day>=1 && day<=maxDay && hour>=0 && hour<=23 && minute>=0 && minute<=59 && second>=0 && second<=59) {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:day];
            [components setMonth:month];
            [components setYear:year];
            [components setHour:hour];
            [components setMinute:minute];
            [components setSecond:second];
            
            datetime = [[NSCalendar currentCalendar] dateFromComponents:components];
        }
    }
    
    return datetime;
    
}

+ (BOOL)date: (NSDate *)givenDate isWithinEarliestDate: (NSDate *)earliestDate toLatestDate: (NSDate *)latestDate {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newGivenDate = [DateCalculator dateWithoutTime:givenDate];
    NSDate *newEarliestDate = [DateCalculator dateWithoutTime:earliestDate];
    NSDate *newLatestDate = [DateCalculator dateWithoutTime:latestDate];
    
    if ( ([newEarliestDate compare:newGivenDate] == NSOrderedAscending || [newEarliestDate compare:newGivenDate] == NSOrderedSame) && ([newLatestDate compare:newGivenDate] == NSOrderedDescending || [newLatestDate compare:newGivenDate] == NSOrderedSame)) {
        
        // earliest date <= given date and latest date >= given date
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)date: (NSDate *)date1 isEarlierThan: (NSDate *)date2 {

    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newDate1 = [DateCalculator dateWithoutTime:date1];
    NSDate *newDate2 = [DateCalculator dateWithoutTime:date2];

    if ( [newDate1 compare:newDate2] == NSOrderedAscending ) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)date: (NSDate *)date1 isLaterThan: (NSDate *)date2 {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newDate1 = [DateCalculator dateWithoutTime:date1];
    NSDate *newDate2 = [DateCalculator dateWithoutTime:date2];

    if ( [newDate1 compare:newDate2] == NSOrderedDescending ) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)date: (NSDate *)date1 isSameAs: (NSDate *)date2 {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newDate1 = [DateCalculator dateWithoutTime:date1];
    NSDate *newDate2 = [DateCalculator dateWithoutTime:date2];

    if ( [newDate1 compare:newDate2] == NSOrderedSame ) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSInteger)monthsBetween: (NSDate *)date1 and:(NSDate *)date2 {
    
    NSDate *laterDate;
    NSDate *earlierDate;
    
    if ([DateCalculator date:date2 isLaterThan:date1]) {
        laterDate = date2;
        earlierDate = date1;
    } else {
        // date 1 could be later than date2 or the same as date 2, but math will be ok either way
        laterDate = date1;
        earlierDate = date2;
    }
    
    NSInteger earlierYear = [DateCalculator yearFor:earlierDate];
    NSInteger earlierMonth = [DateCalculator monthFor:earlierDate];
    NSInteger laterYear = [DateCalculator yearFor:laterDate];
    NSInteger laterMonth = [DateCalculator monthFor:laterDate];
    
    NSInteger monthsBetween;
    
    if (earlierYear == laterYear) {
        monthsBetween = laterMonth - earlierMonth;
    }
    else {
        monthsBetween = 12 - earlierMonth;
        
        monthsBetween += 12 * (laterYear - earlierYear - 1);
        
        monthsBetween += laterMonth;
    }

    return monthsBetween;
}

+ (NSDate *)dateThatIs: (NSInteger)days daysEarlierThan:(NSDate *)givenDate {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newGivenDate = [DateCalculator dateWithoutTime:givenDate];

    NSDate *newDate = [DateCalculator dateThatIs:-1 * days daysLaterThan:newGivenDate];
    
    return newDate;
}

+ (NSDate *)dateThatIs: (NSInteger)days daysLaterThan:(NSDate *)givenDate {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newGivenDate = [DateCalculator dateWithoutTime:givenDate];

    NSDateComponents *dc = [[NSDateComponents alloc] init];
    dc.day = days;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *newDate = [cal dateByAddingComponents:dc toDate:newGivenDate options:0];
    
    return newDate;
}

+ (NSDate *)dateThatIs: (NSInteger)months monthsEarlierThan:(NSDate *)givenDate {

    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newGivenDate = [DateCalculator dateWithoutTime:givenDate];
    
    NSDate *newDate = [DateCalculator dateThatIs:-1 * months monthsLaterThan:newGivenDate];
    
    return newDate;
}

+ (NSDate *)dateThatIs: (NSInteger)months monthsLaterThan:(NSDate *)givenDate {
    
    // clear all the times so comparisons are truly against dates and not datetime values
    NSDate *newGivenDate = [DateCalculator dateWithoutTime:givenDate];
    
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    dc.month = months;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *newDate = [cal dateByAddingComponents:dc toDate:newGivenDate options:0];
    
    return newDate;
}

+ (NSInteger)yearFor: (NSDate *)date {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear fromDate: date];
    
    return components.year;
}

+ (NSInteger)monthFor: (NSDate *)date {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth fromDate: date];
    
    return components.month;
}

+ (NSInteger)dayFor: (NSDate *)date {

    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay fromDate: date];
    
    return components.day;
}

+ (NSInteger)hourFor: (NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitHour fromDate: date];
    
    return components.hour;
}

+ (NSInteger)minuteFor: (NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitMinute fromDate: date];
    
    return components.minute;
}

+ (NSInteger)secondFor: (NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate: date];
    
    return components.second;
}

+ (NSString *)monthNameLongForDate: (NSDate *)date {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth fromDate: date];
    
    return [DateCalculator monthNameLongForMonth:components.month];
}

+ (NSString *)monthNameLongForMonth: (NSInteger)month {
    
    NSString *monthName;
    
    switch (month) {
        case 1:
            monthName = @"January";
            break;
        case 2:
            monthName = @"February";
            break;
        case 3:
            monthName = @"March";
            break;
        case 4:
            monthName = @"April";
            break;
        case 5:
            monthName = @"May";
            break;
        case 6:
            monthName = @"June";
            break;
        case 7:
            monthName = @"July";
            break;
        case 8:
            monthName = @"August";
            break;
        case 9:
            monthName = @"September";
            break;
        case 10:
            monthName = @"October";
            break;
        case 11:
            monthName = @"November";
            break;
        case 12:
            monthName = @"December";
            break;
            
        default:
            monthName = @"Unknown";
            break;
    }
    return monthName;
}

+ (NSString *)monthNameShortForDate: (NSDate *)date {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth fromDate: date];
    
    return [DateCalculator monthNameShortForMonth:components.month];
}

+ (NSString *)monthNameShortForMonth: (NSInteger)month {
    NSString *monthName;
    
    switch (month) {
        case 1:
            monthName = @"Jan";
            break;
        case 2:
            monthName = @"Feb";
            break;
        case 3:
            monthName = @"Mar";
            break;
        case 4:
            monthName = @"Apr";
            break;
        case 5:
            monthName = @"May";
            break;
        case 6:
            monthName = @"Jun";
            break;
        case 7:
            monthName = @"Jul";
            break;
        case 8:
            monthName = @"Aug";
            break;
        case 9:
            monthName = @"Sep";
            break;
        case 10:
            monthName = @"Oct";
            break;
        case 11:
            monthName = @"Nov";
            break;
        case 12:
            monthName = @"Dec";
            break;
            
        default:
            monthName = @"Unknown";
            break;
    }
    return monthName;
}

@end
