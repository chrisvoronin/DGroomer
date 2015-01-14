//
//  ActivateAccountViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAActivateAccountViewController.h"
#import "PSAVerifyViewController.h"

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

- (IBAction)clicked_btnNext:(id)sender {
    if (!self.chkBtnAgreeCheckMark.isSelected) {
        return;
    }
    
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    if (!isValid) {
        return;
    }
    //[self dismissViewControllerAnimated:YES completion:^{}];
    
    PSAVerifyViewController *pvc = [[PSAVerifyViewController alloc] initWithNibName:@"PSAVerifyViewController" bundle:nil];
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
