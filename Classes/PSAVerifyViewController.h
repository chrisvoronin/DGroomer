//
//  PSAVerifyViewController.h
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRegistrationViewController.h"

@interface PSAVerifyViewController : BaseRegistrationViewController
@property (retain, nonatomic) IBOutlet UILabel *lblPhoneChange;
@property (retain, nonatomic) IBOutlet UITextField *txtVerifyCode;

@end
