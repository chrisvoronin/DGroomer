//
//  ActivateAccountViewController.h
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ValidationUtility.h"

@interface PSAActivateAccountViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lblTerms;
@property (retain, nonatomic) IBOutlet UIButton *chkBtnAgreeCheckMark;
@property (nonatomic, strong) ValidationUtility* validation;
@property (retain, nonatomic) IBOutlet UITextField *txtName;
@property (retain, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UITextField *txtPhone;

@end
