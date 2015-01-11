//
//  PSABaseViewController.m
//  iBiz
//
//  Created by Olexandr Shelestyuk on 12/24/13.
//  Copyright (c) 2013 SalonTechnologies, Inc. All rights reserved.
//

#import "PSABaseViewController.h"

@interface PSABaseViewController ()

@end

@implementation PSABaseViewController

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
	// Do any additional setup after loading the view.
    
    //For layout in iOS7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
