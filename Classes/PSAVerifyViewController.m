//
//  PSAVerifyViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAVerifyViewController.h"
#import "PSAConfirmationViewController.h"
#import "ConfigurationUtility.h"
#import "DataRegister.h"
#import "Company.h"
#import "PSADataManager.h"

@interface PSAVerifyViewController ()

@end

@implementation PSAVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.lblPhoneChange.attributedText = [[NSAttributedString alloc] initWithString:@"Verify or change the phone number" attributes:underlineAttribute];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
    //Do stuff here...
}
- (IBAction)txtChanged:(id)sender {
    if (self.txtVerifyCode.text.length == 4) {
        //NSString *str = self.txtVerifyCode.text;
        //self.txtVerifyCode.text = [str substringToIndex:4];
        [self.txtVerifyCode resignFirstResponder];
    }
}

- (IBAction)clicked_changephone:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
}
- (IBAction)clicked_verify:(id)sender {
    
    NSString *strCode = self.txtVerifyCode.text;
    if (strCode.length < 1) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Please input verification code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if(![strCode isEqualToString:self.txtCode])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Incorrect verification code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self submitForm];
    
}
- (IBAction)clicked_back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
}


- (void) progressTask
{
    /*NSDictionary * dict = nil;
     dict = @{
     @"source" : @"ApiTest",
     @"originator" : @"1029",
     @"returnType" : @"jsonP",
     @"businessName" : self.txtBusinessName.text,
     @"contactName" : self.txtName.text,
     @"phone" : self.txtPhone.text,
     @"email" : self.txtEmail.text,
     @"phoneAlt" : @"",
     @"traceId" : @"test"
     };*/
    
    NSString *strDict = [NSString stringWithFormat:@"source=DOGG&originator=1030&returnType=xml&phoneAlt=&businessName=%@&contactName=%@&phone=%@&email=%@&", self.txtBusinessName, self.txtName, self.txtPhone, self.txtEmail];
    
    self.dal = [[ServiceDAL alloc] initWiThHttpPostData:strDict urlString:URL_MERCHANT_ACTIVEACCOUNT delegate:self];
    [self.dal startAsync];
}

- (void) handleServiceResponseErrorMessage:(NSString *)error
{
    [self.progress hide:YES];
    
    if (error != nil && ![error isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:@"Unexpected Server Error!" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void) handleServiceResponseWithDict:(NSDictionary *)dictionary
{
    [self.progress hide:YES];
    
    if ([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_ACTIVEACCOUNT]) {
        NSString *strSucess = [[[[dictionary objectForKey:@"ApiResponse"] objectForKey:@"Success"] objectForKey:@"text"] substringFromIndex:3];
        NSString *strLeanId = [[[[dictionary objectForKey:@"ApiResponse"] objectForKey:@"LeadId"] objectForKey:@"text"] substringFromIndex:3];
        if([strSucess isEqualToString:@"true"])
        {
            self.LeadId = strLeanId;
            [[DataRegister instance] getBussinessItem].businessName = self.txtBusinessName;
            [[DataRegister instance] getBussinessItem].email = self.txtEmail;
            [[DataRegister instance] getBussinessItem].phone = self.txtPhone;
            
            Company	*company = [[PSADataManager sharedInstance] getCompany];
            company.companyName = self.txtBusinessName;
            company.companyEmail = self.txtEmail;
            company.companyPhone = self.txtPhone;
            [[PSADataManager sharedInstance] updateCompany:company];
        }
        else{
            /*UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Failed to send verification code."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
            [alert release];
            return;*/
        }
    }
    
    PSAConfirmationViewController *pvc = [[PSAConfirmationViewController alloc] initWithNibName:@"PSAConfirmationViewController" bundle:nil];
    [self presentViewController:pvc animated:NO completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_lblPhoneChange release];
    [_txtVerifyCode release];
    [super dealloc];
}
@end
