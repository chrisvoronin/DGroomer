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
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)clicked_btnNext:(id)sender {
    if (!self.chkBtnAgreeCheckMark.isSelected) {
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
    [super dealloc];
}
@end
