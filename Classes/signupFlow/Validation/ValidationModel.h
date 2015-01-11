//
//  ValidationModel.h
//  CashRegister
//
//  Created by Olexandr Shelestyuk on 12/17/13.
//
//  Copyright (c) 2013 Chris Voronin. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum ValidationType : NSUInteger {
    ValidationEmail = 0,
    ValidationEmpty = 1,
    ValidationZipCode = 2,
    ValidationABA = 3,
    ValidationNumbersOnly = 4,
    ValidationFullName = 5,
    ValidationMinLength = 6,
    ValidationPhone = 7,
    ValidationMustMatch = 8,
    ValidationExactLength = 9
} ValidationType;

@interface ValidationModel : NSObject

@property (nonatomic, retain) id<UITextInput> field;
@property (nonatomic, assign) ValidationType validationType;
@property (nonatomic, assign) int length;
@property (nonatomic, retain) id<UITextInput> fieldMatch;

-(id)initWithField:(id<UITextInput>)f andValidationType:(ValidationType)valType andLength:(int)length;

-(id)initWithField:(id<UITextInput>)f andValidationType:(ValidationType)valType;

-(id)initWithField:(id<UITextInput>)f mustMatch:(id<UITextInput>)fmatch;

@end
