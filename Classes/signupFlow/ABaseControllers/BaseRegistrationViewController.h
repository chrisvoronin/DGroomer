//
//  BaseRegistrationViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ValidationUtility.h"
#import "ServiceDAL.h"
#import "ServiceProtocol.h"

@interface BaseRegistrationViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate, ServiceProtocol>

@property (nonatomic, strong) ServiceDAL *dal;
@property (nonatomic, strong) MBProgressHUD* progress;
@property (nonatomic, strong) ValidationUtility* validation;

-(void)startTaskWithProgressTitle:(NSString*)title;

-(void)progressTask;

-(void)submitForm;

- (void)showCustomPickerView:(NSArray*)pStringArray selectedString:(id)pSelectedString target:(id)pTarget;

- (void)showCustomDatePickerViewWithMindate:(NSDate*)dateMin
                                    maxDate:(NSDate*)dateMax
                               selectedDate:(NSDate*)dateSelected
                                     target:(id)pTarget;

@end
