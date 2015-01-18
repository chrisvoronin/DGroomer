//
//  TermsAndConditionsViewController.m
//  SmartSwipe
//
//  Created by Olexandr Shelestyuk on 10/28/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "TermsAndConditionsViewController.h"

@interface TermsAndConditionsViewController ()

@end

@implementation TermsAndConditionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Terms & Conditions";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)onBack:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
