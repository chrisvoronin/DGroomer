//
//  MMDatePickerView.h
//  SmartSwipe
//
//  Created by Chris Voronin on 11/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMDatePickerView: UIView

+(void)showPickerViewInView: (UIView *)view
                withDate: (NSDate *)date
                withMinDate:(NSDate *)dateMin
                withMaxDate:(NSDate *)dateMax
                withOptions:(NSDictionary*)options
                 completion: (void(^)(NSString *selectedString))completion;

+(void)dismissWithCompletion: (void(^)(NSString *))completion;

@end
