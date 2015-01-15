//
//  AddGroupController.m
//  myBusiness
//
//  Created by David J. Maier on 6/14/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "ServiceGroup.h"
#import "ServiceGroupViewController.h"

@implementation ServiceGroupViewController

@synthesize group, txtGroupName;


- (void) viewDidLoad {
	self.title = @"GROUP";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundPurple.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	txtGroupName.frame = CGRectMake( txtGroupName.frame.origin.x, txtGroupName.frame.origin.y, txtGroupName.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	if( group == nil )	group = [[ServiceGroup alloc] init];
	txtGroupName.text = group.groupDescription;
	[txtGroupName becomeFirstResponder];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[txtGroupName release];
	[group release];
    [super dealloc];
}

- (void) save {
	if( txtGroupName.text.length > 0 ) {
		group.groupDescription = txtGroupName.text;
		[[PSADataManager sharedInstance] saveServiceGroup:group];
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Service Group" message:@"You must enter a name for this group." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}	
}

-(void) cancelAdd{
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
