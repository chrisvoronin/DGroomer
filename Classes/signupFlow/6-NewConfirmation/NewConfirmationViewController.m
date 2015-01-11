//
//  NewConfirmationViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "NewConfirmationViewController.h"

@interface NewConfirmationViewController ()


@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@end

@implementation NewConfirmationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Confirmation";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    UITapGestureRecognizer * recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapLabel:)];
    [lblCall addGestureRecognizer:recog];
}


- (void)onTapLabel:(UITapGestureRecognizer*)recog\
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"877-976-8218" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.tag = 10;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10){
        if(buttonIndex == 1){
            NSString *URLString = @"tel://877-976-8218";
            NSURL *URL = [NSURL URLWithString:URLString];
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
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

#pragma mark - Actions

- (IBAction)onClick_btnMakePhoneCall:(id)sender {
    //TODO
}

- (IBAction)onClick_btnDone:(id)sender {
    //TODO
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dealloc {
    [self.scrollView release];
    [self.contentView release];
    [lblCall release];
    [super dealloc];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
