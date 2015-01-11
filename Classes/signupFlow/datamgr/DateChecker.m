//
//  DateChecker.m
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/24/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "DateChecker.h"

@implementation DateChecker
+ (int)getDateNumbers:(NSString*)dateStr :(NSString*)dateformat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateformat];
    NSDate * date = [formatter dateFromString:dateStr];
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return components.year * 10000 + components.month * 100 + components.day;
}
- (int)getDateNumbers:(NSDate*)dateStr
{
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dateStr];
    return components.year * 10000 + components.month * 100 + components.day;
}
+(BOOL)isToday:(NSString*)dateStr :(NSString*)dateformat
{
    DateChecker * checker = [DateChecker new];
    int selectDateNumber  = [DateChecker getDateNumbers:dateStr :dateformat];
    int currentDateNumber = [checker getDateNumbers:[NSDate date]];
    if(selectDateNumber == currentDateNumber)
        return YES;
    return NO;
}
+(NSString *)getDescriptDateString:(NSString*)dateStr :(NSString*)dateFormatter
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    NSDate * date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:@"MMM dd,yyyy"];
    NSString * tmpStr = [formatter stringFromDate:date];
    return tmpStr;
}
+(BOOL)isThisMonth:(NSString*)dateStr :(NSString*)dateformat
{
    DateChecker * checker = [DateChecker new];
    int value = abs([DateChecker getDateNumbers:dateStr :dateformat] - [checker getDateNumbers:[NSDate date]]);
    if(value < 100)
        return YES;
    return NO;
}
+(BOOL)isTimedIn:(NSString*)dateStr :(NSString*)format1 :(NSString*)stTime :(NSString*)edTime :(NSString*)format2
{
    int currentValue = [DateChecker getDateNumbers:dateStr :format1];
    int stValue = [DateChecker getDateNumbers:stTime :format2];
    int edValue = [DateChecker getDateNumbers:edTime :format2];
    if(currentValue >= stValue && currentValue<= edValue)
        return YES;
    return NO;
}
@end
