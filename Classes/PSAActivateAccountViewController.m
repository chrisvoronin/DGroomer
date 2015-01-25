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
@synthesize txtPhone;

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
    //[self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPhone andValidationType:ValidationPhone]];
    self.txtPhone.delegate = self;
    [self.chkBtnAgreeCheckMark setSelected:NO];
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
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Pleasae read and agree Terms & Conditions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
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
    m_code = arc4random() % 9000 + 1000;
    NSString *strDict = [[NSString stringWithFormat:@"?phone=%@&text=Here is your activation code. %ld. Thank you for choosing Dog Groomer!&token=raj12345", self.txtPhone.text, (long)m_code] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //[strDict stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    self.dal = [[ServiceDAL alloc] initWiThHttpGetData:strDict urlString:URL_MERCHANT_SENDMESSAGE delegate:self];
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
    
   
 
    PSAVerifyViewController *pvc = [[PSAVerifyViewController alloc] initWithNibName:@"PSAVerifyViewController" bundle:nil];
    pvc.txtCode = [NSString stringWithFormat:@"%d", m_code];
    pvc.txtBusinessName = self.txtBusinessName.text;
    pvc.txtName = self.txtName.text;
    pvc.txtPhone = self.txtPhone.text;
    pvc.txtEmail = self.txtEmail.text;
    [self presentViewController:pvc animated:NO completion:nil];
    
}

- (IBAction)clicked_Agree:(id)sender {
    [self.chkBtnAgreeCheckMark setSelected:!self.chkBtnAgreeCheckMark.isSelected];
}
- (IBAction)clicked_Terms:(id)sender {

}




/*- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // enter closes the keyboard
    if(textField == self.txtPhone)
    {
        
        if(self.txtPhone.text.length>9)
        {
            self.txtPhone.text = phone;
            [textField resignFirstResponder];
            return NO;
        }
        else
            phone = self.txtPhone.text;
    }
    return YES;
}
*/

- (IBAction)txtchanged:(id)sender {
    if (self.txtPhone.text.length == 11) {
        NSString *str = self.txtPhone.text;
        self.txtPhone.text = [str substringToIndex:10];
        [self.txtPhone resignFirstResponder];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    //textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
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
    [txtPhone release];
    
    [super dealloc];
}
@end
