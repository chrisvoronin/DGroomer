//
//  PSAConfirmationViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAConfirmationViewController.h"
#import "PSAAppDelegate.h"

@interface PSAConfirmationViewController ()

@end

@implementation PSAConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clicked_GetStarted:(id)sender {
    //[self.window setRootViewController:navigationController]; // iOS 6 autorotation fix
    //[window addSubview:navigationController.view];
    //store the flag so it exists the next time the app starts
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@"firstRun"];
    [(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapClientTabWithNavigation];
    
//
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
