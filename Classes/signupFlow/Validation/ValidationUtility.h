//
//  ValidationUtility.h
//  CashRegister
//
//  Created by Olexandr Shelestyuk on 12/17/13.
//
//  Copyright (c) 2013 Chris Voronin. All rights reserved.

#import <Foundation/Foundation.h>
#import "ValidationModel.h"

@interface ValidationUtility : NSObject

@property (nonatomic, retain) NSString * alertMessage;
@property (nonatomic, retain) NSString * alertTitle;
@property (nonatomic, retain) UIColor * colorValid;
@property (nonatomic, retain) UIColor * colorNotValid;

-(id)initWithAlertMessage:(NSString*)message andTitle:(NSString*)title andValidColor:(UIColor*)valid andNotValidColor:(UIColor*)invalid;

-(void)addValidationModel:(ValidationModel*)model;

-(BOOL)validateFormAndShowAlert:(BOOL)showAlert;

@end
