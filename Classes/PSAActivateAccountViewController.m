//
//  ActivateAccountViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAActivateAccountViewController.h"
#import "PSAVerifyViewController.h"
#import "ConfigurationUtility.h"
#import "DataRegister.h"

@interface PSAActivateAccountViewController ()

@end

@implementation PSAActivateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.lblTerms.attributedText = [[NSAttributedString alloc] initWithString:@"Terms & Conditions"
                                                             attributes:underlineAttribute];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor darkGrayColor] andNotValidColor:[UIColor redColor]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtName andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtBusinessName andValidationType:ValidationMinLength andLength:4]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtEmail andValidationType:ValidationEmail]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPhone andValidationType:ValidationPhone]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [self.view endEditing:YES];
    //Do stuff here...
}
- (IBAction)clicked_terms:(id)sender {
    TermsAndConditionsViewController *pvc = [[TermsAndConditionsViewController alloc] initWithNibName:@"TermsAndConditionsViewController" bundle:nil];
    [self presentViewController:pvc animated:NO completion:nil];
}

- (IBAction)clicked_btnNext:(id)sender {
    if (!self.chkBtnAgreeCheckMark.isSelected) {
        return;
    }
    
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    if (!isValid) {
        return;
    }
    //[self dismissViewControllerAnimated:YES completion:^{}];
    
    [self submitForm];
    
    
    
    
    
    
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
    
    NSString *strDict = [NSString stringWithFormat:@"source=ApiTest&originator=1029&returnType=xml&phoneAlt=&businessName=%@&contactName=%@&phone=%@&email=%@&", self.txtBusinessName.text, self.txtName.text, self.txtPhone.text, self.txtEmail.text];
    
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
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Failed to send verification code."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
            [alert release];
            return;
        }
    }
    
    PSAVerifyViewController *pvc = [[PSAVerifyViewController alloc] initWithNibName:@"PSAVerifyViewController" bundle:nil];
    pvc.LeadId = self.LeadId;
    [self presentViewController:pvc animated:NO completion:nil];
    
}

- (IBAction)clicked_Agree:(id)sender {
    [self.chkBtnAgreeCheckMark setSelected:!self.chkBtnAgreeCheckMark.isSelected];
}
- (IBAction)clicked_Terms:(id)sender {

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
    [_chkBtnAgreeCheckMark release];
    [_lblTerms release];
    [_txtName release];
    [_txtBusinessName release];
    [_txtEmail release];
    [_txtPhone release];
    [super dealloc];
}
@end
