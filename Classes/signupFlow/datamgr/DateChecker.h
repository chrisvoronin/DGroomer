//
//  DateChecker.h
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 12/24/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateChecker : NSObject
+ (int)getDateNumbers:(NSString*)dateStr :(NSString*)dateformat;
+(BOOL)isToday:(NSString*)dateStr :(NSString*)dateformat;
+(BOOL)isThisMonth:(NSString*)dateStr :(NSString*)dateformat;
+(BOOL)isTimedIn:(NSString*)dateStr :(NSString*)format1 :(NSString*)stTime :(NSString*)edTime :(NSString*)format2;
+(NSString *)getDescriptDateString:(NSString*)dateStr :(NSString*)dateFormatter;
@end
