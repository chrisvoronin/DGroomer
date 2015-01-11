//
//  NewAccountViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "CreateUserIDPassword_iPhone.h"
#import "NewBusinessInfoViewController.h"
//#import "DataRegister.h"
//#import "ErrorXmlParser.h"
#//import "ResponseXmlParser.h"
#import "ServiceDAL.h"
//#import "ConfigurationUtility.h"
//#import "Cheap_CCPAppDelegate.h"
//#import "ApplicationStateManager.h"

@interface CreateUserIDPassword_iPhone () {
    UITextField *activeField;
}

@property (retain, nonatomic) IBOutlet UITextField *txtFirstName;
@property (retain, nonatomic) IBOutlet UITextField *txtLastName;
@property (retain, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;


@end

@implementation CreateUserIDPassword_iPhone

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Create User ID and Password";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self initValidations];
}

- (void) initValidations {
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor darkGrayColor] andNotValidColor:[UIColor redColor]];
    
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtFirstName andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtLastName andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtBusinessName andValidationType:ValidationMinLength andLength:4]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtEmail andValidationType:ValidationEmail]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPhoneNumber andValidationType:ValidationPhone]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPassword andValidationType:ValidationMinLength andLength:6]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtConfirmPassword mustMatch:self.txtPassword]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_txtFirstName release];
    [_txtLastName release];
    [_txtBusinessName release];
    [_txtEmail release];
    [_txtPhoneNumber release];
    [_txtPassword release];
    [_txtConfirmPassword release];

    [scrollView release];
    [_contentView release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.contentView convertRect:CGRectZero fromView:textField];
    int delta = textFieldRect.origin.y + 65 + 100 - self.view.frame.size.height + 216;
    if (delta < 0) {
        delta = 0;
    }
    [self.scrollView  setContentOffset:CGPointMake(0, delta) animated:YES];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtFirstName) {
        [self.txtLastName becomeFirstResponder];
    
    } else if (textField == self.txtLastName) {
        [self.txtBusinessName becomeFirstResponder];
    
    } else if (textField == self.txtBusinessName) {
        [self.txtEmail becomeFirstResponder];
    
    } else if (textField == self.txtEmail) {
        [self.txtPhoneNumber becomeFirstResponder];
    
    } else if (textField == self.txtPhoneNumber) {
        [self.txtPassword becomeFirstResponder];
    
    } else if (textField == self.txtPassword) {
        [self.txtConfirmPassword becomeFirstResponder];
    
    } else if (textField == self.txtConfirmPassword) {
        [self onClick_btnNext:nil];
    }
    
    return NO;
}

#pragma mark - Actions

- (IBAction)onClick_btnNext:(id)sender {
    [[DataRegister instance] getMerchantItem].BussinessName = self.txtBusinessName.text;
    [[DataRegister instance] getMerchantItem].FirstName = self.txtFirstName.text;
    [[DataRegister instance] getMerchantItem].lastName = self.txtLastName.text;
    [[DataRegister instance] getMerchantItem].EMail = self.txtEmail.text;
    [[DataRegister instance] getMerchantItem].Password = self.txtPassword.text;
    [[DataRegister instance] getMerchantItem].PhoneNum = self.txtPhoneNumber.text;
    
    [self submitForm];
}

#pragma mark - Form Submission
/*
 request code:
 
 {
    "rqd": {
        "fn": "Mike",
        "ln": "Doe",
        "bn": "Doe Bakery",
        "em": "abc@abc.net",
        "pn": "123-456-9870",
        "pwd": "1111"
    },
    "sd": {
        "mid": 123,
        "uem": "user@abc.net",
        "uid": 987,
        "ldk": "Mobile123"
    }
 }
*/
/*
 response code:
 
 {
    "rsd": {
        "mid": 5
    },
    "st": 0,
    "er": null
 }
 */
/*
 error code:
 
 {
    "rsd": {
 
    },
    "st": 1,
    "er": {
    "ec": 2,
    "em": "This email already in use."
    }
 }
 */
-(void)progressTask
{
    NSDictionary * dict1 = @{
                             @"fn" : [[DataRegister instance] getMerchantItem].FirstName,
                             @"ln" : [[DataRegister instance] getMerchantItem].lastName,
                             @"bn" : [[DataRegister instance] getMerchantItem].BussinessName,
                             @"em" : [[DataRegister instance] getMerchantItem].EMail,
                             @"pn" : [[DataRegister instance] getMerchantItem].PhoneNum,
                             @"pwd" : [[DataRegister instance] getMerchantItem].Password/*,
                                                                                         @"LeadKey" : [ConfigurationUtility getLeadKey],*/
                             };
    self.dal = [[ServiceDAL alloc] initWiThPostData:dict1 urlString:URL_MERCHANT_REGISTER delegate:self];
    [self.dal startAsync];
}

-(void)handleServiceResponseWithDict:(NSDictionary*)dictionary
{
    int merchantKey = 0;
    if([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_REGISTER]){
        /// new account success
        int mechantId = [[ResponseXmlParser getResponseDataForKey:@"mid" :dictionary] intValue];
        [[DataRegister instance] getMerchantItem].MerchantID = mechantId;
        merchantKey = mechantId;
    }
    
    // save values
    NSString *strMerchantKey = [NSString stringWithFormat:@"%d", merchantKey];
    [ApplicationStateManager setMerchantKey:strMerchantKey];
    [ApplicationStateManager setMerchantFullName:[self.txtFirstName.text stringByAppendingString:self.txtLastName.text]];
    [ApplicationStateManager setBusinessName:self.txtBusinessName.text];
    [ApplicationStateManager setEmail:self.txtEmail.text];
    [ApplicationStateManager setPhoneNumber:self.txtPhoneNumber.text];
    [ApplicationStateManager setPassword:self.txtPassword.text];
    
    // goto page to add businessinfo
    NewBusinessInfoViewController *viewctrl = [[NewBusinessInfoViewController alloc] initWithBusinessName:self.txtBusinessName.text merchantKey:merchantKey phone:self.txtPhoneNumber.text];
    [self.navigationController pushViewController:viewctrl animated:YES];
}

@end
