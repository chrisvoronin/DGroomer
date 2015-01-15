//
//  AddServicesNameController.m
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Service.h"
#import "ServiceNameViewController.h"


@implementation ServiceNameViewController

@synthesize txtName, service, swActive;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"SERVICE NAME";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundPurple.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	txtName.frame = CGRectMake( txtName.frame.origin.x, txtName.frame.origin.y, txtName.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( service ) {
		txtName.text = service.serviceName;
		swActive.on = service.isActive;
	}
	[txtName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.txtName = nil;
	self.swActive = nil;
	[service release];
    [super dealloc];
}


- (void) save {
	if( service ) {
		service.serviceName = txtName.text;
		service.isActive = swActive.on;
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end
