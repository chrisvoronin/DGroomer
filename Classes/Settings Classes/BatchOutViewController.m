//
//  BatchOutViewController.m
//  iBiz
//
//  Created by johnny on 2/15/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "BatchOutViewController.h"

@interface BatchOutViewController ()

@end

@implementation BatchOutViewController
@synthesize lblTime, ctrlTimer;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate* currentDate1 = [NSDate date];
    lblTime.text = [formatter stringFromDate:currentDate1];
    [formatter release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction) timeChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    lblTime.text = [formatter stringFromDate:ctrlTimer.date];
    [formatter release];
}

- (void)dealloc {
    [lblTime release];
    [ctrlTimer release];
    [super dealloc];
}
@end
