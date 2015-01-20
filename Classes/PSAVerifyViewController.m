//
//  PSAVerifyViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAVerifyViewController.h"
#import "PSAConfirmationViewController.h"

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
    if(![strCode isEqualToString:self.LeadId])
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Incorrect verification code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    PSAConfirmationViewController *pvc = [[PSAConfirmationViewController alloc] initWithNibName:@"PSAConfirmationViewController" bundle:nil];
    [self presentViewController:pvc animated:NO completion:nil];
}
- (IBAction)clicked_back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
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
