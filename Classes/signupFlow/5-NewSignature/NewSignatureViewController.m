//
//  NewSignatureViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "NewSignatureViewController.h"


@interface NewSignatureViewController ()
{
    long merchantKey;
    NSString * fullName;
    
    BOOL    canRotateToAllOrientations;
}
@end

@implementation NewSignatureViewController

-(id)initWithMerchantKey:(long)mKey andFullName:(NSString*)fName
{
    self = [super initWithNibName:@"NewSignatureViewController" bundle:nil];
    if (self)
    {
        merchantKey = mKey;
        fullName = fName;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    self.lblFullName.text = fullName;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    canRotateToAllOrientations = YES;
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    canRotateToAllOrientations = YES;
//    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Form Submission
/*
 Request code:
 
{
    "rqd": {
        "si": "http://www.abc.net/images/signature.jpg"
    },
    "sd": {
        "mid": 123,
        "ldk": "Mobile123"
    }
}
 */


#pragma mark - Rotate Routine

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}




/*- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation // iOS 6 autorotation fix
{
    return UIInterfaceOrientationPortrait;
}*/

#pragma mark - Actions

- (IBAction)onClick_btnClear:(id)sender {
    //TODO
    self.imgSign.image = nil;
}

- (IBAction)onClick_btnSubmit:(id)sender {
    //TODO
    
//    NewConfirmationViewController *vc = [[NewConfirmationViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];

    //For Landscape Mode
    [self dismissViewControllerAnimated:NO completion:^(){
        [self.delegate signatureCompleted];
    }];
}



- (void)dealloc {
    [_imgSign release];
    [super dealloc];
}
@end
