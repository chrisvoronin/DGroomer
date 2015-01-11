//
//  ValidationUtility.m
//  CashRegister
//
//  Created by Olexandr Shelestyuk on 12/17/13.
//
//  Copyright (c) 2013 Chris Voronin. All rights reserved.

#import "ValidationUtility.h"

@interface ValidationUtility()

@property (nonatomic, retain) NSMutableArray * validationList;

@end

@implementation ValidationUtility

- (void)dealloc {
    [super dealloc];
    
    [_validationList removeAllObjects];
    _validationList = nil;
}

-(id)initWithAlertMessage:(NSString*)message andTitle:(NSString*)title andValidColor:(UIColor*)valid andNotValidColor:(UIColor*)invalid
{
    self = [super init];
    if (self)
    {
        self.alertMessage = message;
        self.alertTitle = title;
        self.colorValid = valid;
        self.colorNotValid = invalid;
        self.validationList = [NSMutableArray array];
    }
    return self;
}

-(void)addValidationModel:(ValidationModel*)model
{
    [self.validationList addObject:model];
}

-(BOOL)validateFormAndShowAlert:(BOOL)showAlert
{
    __block BOOL isValid = YES;
    __block NSString * text;
    __block NSString * title;
    __block NSString * message;
    title = @"Warning";

    [self.validationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ValidationModel *m = obj;
        BOOL isHidden = [self isFieldHidden:m.field];
        BOOL fieldValid = YES;
        if (!isHidden)
        {
            text = [self getTextFromView:m.field];
            
            switch (m.validationType) {
                case ValidationEmail:
                    fieldValid = [self validateEmail:text];
                    message = @"Please input correct email";
                    break;
                case ValidationEmpty:
                    fieldValid = [self validateEmpty:text];
                    message = @"Please input empty field";
                    break;
                case ValidationNumbersOnly:
                    fieldValid = [self validateNumbersOnly:text];
                    message = @"Please input number";
                    break;
                case ValidationFullName:
                    fieldValid = [self validateFullName:text];
                    message = @"Please input correct full name";
                    break;
                case ValidationMinLength:
                    fieldValid = [self validateMinLength:text length:m.length];
                    message = [NSString stringWithFormat:@"Please input more than %d characters", m.length];
                    break;
                case ValidationExactLength:
                    fieldValid = [self validateLength:text length:m.length];
                    message = [NSString stringWithFormat:@"Please input %d characters", m.length];
                    break;
                case ValidationMustMatch:
                {
                    NSString * textMatch = [self getTextFromView:m.fieldMatch];
                    fieldValid = [self validateMatch:text andMatch:textMatch];
                    message = @"Two passwords not match";
                    break;
                }
                case ValidationPhone:
                    fieldValid = [self validatePhone:text];
                    message = @"Please input correct phone number";
                    break;
                default:
                    break;
            }
        }
        
        // set text color and background color
        if (fieldValid) {
//            [self setField:m.field backgroundColor:self.colorValid];
            [self setField:m.field textColor:self.colorValid];
        
        } else {
            isValid = NO;
//            [self setField:m.field backgroundColor:self.colorNotValid];
            [self setField:m.field textColor:self.colorNotValid];
        }
        
        // show alert
        if (!isValid && showAlert) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
            
            // stop to check other validation model
            *stop = YES;
        }
    }];
    
    return isValid;
}

#pragma mark - internal private methods


-(void)setField:(id<UITextInput>)input textColor:(UIColor*)color
{
    if ([input isKindOfClass:[UITextField class]])
    {
        ((UITextField*)input).textColor = color;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        ((UITextView*)input).textColor = color;
    }
}

-(void)setField:(id<UITextInput>)input backgroundColor:(UIColor*)color
{
    if ([input isKindOfClass:[UITextField class]])
    {
        ((UITextField*)input).backgroundColor = color;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        ((UITextView*)input).backgroundColor = color;
    }
}

-(NSString*)getTextFromView:(id<UITextInput>)input
{
    if ([input isKindOfClass:[UITextField class]])
    {
        return ((UITextField*)input).text;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        return ((UITextView*)input).text;
    }
    return @"";
}

-(BOOL)isFieldHidden:(id<UITextInput>)input
{
    if ([input isKindOfClass:[UITextField class]])
    {
        return ((UITextField*)input).isHidden;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        return ((UITextView*)input).isHidden;
    }
    return NO;
}

#pragma mark - Generic Validation

-(BOOL)validateEmail:(NSString*)text
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:text];
}

-(BOOL)validateEmpty:(NSString*)text
{
    text = [self trimSpaces:text];
    
    if(text.length > 0)
    {
        return YES;
    }
    return NO;
}

-(BOOL)validateNumbersOnly:(NSString*)text
{
    NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [text length]; ++i)
    {
        unichar c = [text characterAtIndex:i];
        if (![numberCharSet characterIsMember:c])
        {
            return NO;
        }
    }
    return YES;
}

-(BOOL)validateLength:(NSString*)text length:(int)length
{
    if (text.length == length)
        return YES;
    else
        return NO;
}

-(BOOL)validateMinLength:(NSString*)text length:(int)length
{
    return text.length >= length;
}

-(BOOL)validateRoutingNumber:(NSString*)text
{
    text = [self trimSpaces:text];
    
    if (text.length != 9)
        return NO;
    
    int sum = 0;
    for (int i = 0; i < 9; i++)
    {
        int val = [[text substringWithRange:NSMakeRange(i, 1)] intValue];
        if (i == 0 || i == 3 || i == 6)
            sum += val * 3;
        else if (i == 1 || i == 4 || i == 7)
            sum += val * 7;
        else
            sum += val;
    }
    
    if (sum % 10 == 0)
        return YES;
    else
        return NO;
}

-(BOOL)validateZipCode:(NSString*)text
{
    if ([self validateLength:text length:5] && [self validateNumbersOnly:text])
        return YES;
    return NO;
}

-(BOOL)validateFullName:(NSString*)text
{
    text = [self trimSpaces:text];
    
    NSArray* parts = [text componentsSeparatedByString:@" "];
    return parts.count > 1 && text.length > 7;
}

-(BOOL)validateMatch:(NSString*)text andMatch:(NSString*)text2
{
    if (text.length == 0)
        return NO;
    return [text isEqualToString:text2];
}

-(BOOL)validatePhone:(NSString*)text
{
    if (text.length < 10) {
        return NO;
    }
    
    NSString * numsOnly = [[text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (numsOnly.length >= 10 && ![numsOnly hasPrefix:@"0"])
        return YES;
    else if (numsOnly.length >= 10 && ![numsOnly hasPrefix:@"1"])
        return YES;
    
    return NO;
}

-(NSString*)trimSpaces:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
