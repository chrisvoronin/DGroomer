//
//  BaseRegistrationViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "BaseRegistrationViewController.h"

#import "MMPickerView.h"
#import "MMDatePickerView.h"

@interface BaseRegistrationViewController ()
{
    UITapGestureRecognizer * tapGR;
}
@end

@implementation BaseRegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor whiteColor] andNotValidColor:[UIColor redColor]];
    
    tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tapGR.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGR];
}

-(void)submitForm
{
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    
    if (isValid)
    {
        [self startTaskWithProgressTitle:@"Processing, please wait..."];
    }
}


-(void)startTaskWithProgressTitle:(NSString*)title
{
    UIView * progView = self.navigationController.view;
    if(!progView){
        progView = self.view;
    }
    self.progress = [[MBProgressHUD alloc] initWithView:progView];
    self.progress.dimBackground = YES;
	self.progress.removeFromSuperViewOnHide = YES;
	self.progress.delegate = self;
    self.progress.labelText = title;
    //[self.navigationController.view addSubview:self.progress];
    [self.view addSubview:self.progress];
    [self.progress show:YES];
    [self progressTask];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.progress.delegate = nil;
    [self.progress removeFromSuperview];
    self.progress = nil;
    [super viewWillDisappear:animated];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Smart Swipe" message:@"Base Controller Alert" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

-(void)progressTask
{
    //needs overriding
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up
{
//    const int movementDistance = 60; // tweak as needed
//    const float movementDuration = 0.3f; // tweak as needed
//    
//    int movement = (up ? -movementDistance : movementDistance);
//    
//    [UIView beginAnimations: @"anim" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
//    [UIView commitAnimations];
}

- (void)appEnteredBackground{
    [self hideKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Delegate
-(void)handleServiceResponseErrorMessage:(NSString *)error
{
    [self.progress hide:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)handleServiceResponseWithDict:(NSDictionary *)dictionary
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Not Implemented" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Custom PickerView

- (void)showCustomDatePickerViewWithMindate:(NSDate*)dateMin
                                    maxDate:(NSDate*)dateMax
                               selectedDate:(NSDate*)dateSelected
                                     target:(id)pTarget {
    
    NSDictionary * dict =@{MMbackgroundColor: [UIColor whiteColor],
                          MMtextColor: [UIColor blackColor],
                          MMtoolbarColor: [UIColor lightGrayColor],
                          MMbuttonColor: [UIColor blueColor],
                          MMfont: [UIFont systemFontOfSize:18],
                          MMvalueY: @3,
                          MMtextAlignment:@1};
    
    
    [MMDatePickerView showPickerViewInView:self.view withDate:dateSelected withMinDate:dateMin withMaxDate:dateMax withOptions:dict completion:^(NSString *selectedString) {
        UITextField *textField  = pTarget;
        textField.text          = selectedString;
        if(textField.delegate){
            [textField.delegate textFieldDidEndEditing:textField];
        }
    }];
    
}

- (void)showCustomPickerView:(NSArray*)pStringArray selectedString:(id)pSelectedString target:(id)pTarget {
    
    NSDictionary * dict = @{MMbackgroundColor: [UIColor whiteColor],
                            MMtextColor: [UIColor blackColor],
                            MMtoolbarColor: [UIColor lightGrayColor],
                            MMbuttonColor: [UIColor blueColor],
                            MMfont: [UIFont systemFontOfSize:18],
                            MMvalueY: @3,
                            MMselectedObject:pSelectedString,
                            MMtextAlignment:@1};
    
    //Test code for pickerview, add by shelestyuk : 11/11/2013
    [MMPickerView showPickerViewInView:self.view
                           withStrings:pStringArray
                           withOptions:dict
                            completion:^(NSString *selectedStr) {
                                
                                //Suppose target is textfield only, would be update later
                                UITextField *textField  = pTarget;
                                textField.text          = selectedStr;
                            }];
    
}
@end
