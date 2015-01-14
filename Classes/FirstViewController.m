//
//  FirstViewController.m
//  iBiz
//
//  Created by johnny on 1/13/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "FirstViewController.h"
#import "PSAActivateAccountViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.ctlPage addTarget:self action:@selector(changepage:) forControlEvents:UIControlEventTouchUpInside];
    
    self.mainScroll.delegate        = self;
    self.mainScroll.pagingEnabled   = YES;
    self.mainScroll.contentSize     = CGSizeMake(self.mainScroll.frame.size.width * 5, 1.f);
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    UIImageView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    imgView.image=[UIImage imageNamed:@"clients.png"];
    [newView addSubview:imgView];
    [imgView release];
    [self.mainScroll addSubview:newView];
    [newView release];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(320,0,320,388)];
    imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    imgView.image=[UIImage imageNamed:@"schedule.png"];
    [newView addSubview:imgView];
    [imgView release];
    [self.mainScroll addSubview:newView];
    [newView release];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(640,0,320,388)];
    imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    imgView.image=[UIImage imageNamed:@"getpaid.png"];
    [newView addSubview:imgView];
    [imgView release];
    [self.mainScroll addSubview:newView];
    [newView release];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(960,0,320,388)];
    imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    imgView.image=[UIImage imageNamed:@"services.png"];
    [newView addSubview:imgView];
    [imgView release];
    [self.mainScroll addSubview:newView];
    [newView release];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(1280,0,320,388)];
    imgView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,388)];
    imgView.image=[UIImage imageNamed:@"products.png"];
    [newView addSubview:imgView];
    [imgView release];
    [self.mainScroll addSubview:newView];
    [newView release];
    
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

-(void)changepage:(id)sender
{
    NSInteger page = self.ctlPage.currentPage;
    if (page < 0)
        return;
    if (page >= 5)
        return;
    CGRect frame = self.mainScroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.mainScroll scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWith    = self.mainScroll.frame.size.width;
    int pageNumber      = floor((self.mainScroll.contentOffset.x - pageWith / 2) / pageWith) + 1;
    
    self.ctlPage.currentPage = pageNumber;
}

- (void)dealloc {
    [_ctlPage release];
    [_imgBackground release];
    [_btnActivate release];
    [_mainScroll release];
    [super dealloc];
}
- (IBAction)clicked_btnActivate:(id)sender {
    PSAActivateAccountViewController *pvc = [[PSAActivateAccountViewController alloc] initWithNibName:@"PSAActivateAccountViewController" bundle:nil];
    [self presentViewController:pvc animated:NO completion:nil];

}
@end
