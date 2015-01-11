//
//  ProjectNameEntryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectNameEntryViewController.h"


@implementation ProjectNameEntryViewController

@synthesize invoice, project, txtField;

- (void) viewDidLoad {
	if( project ) {
		self.title = @"Project Name";
	} else if( invoice ) {
		if( invoice.type == iBizProjectInvoice ) {
			self.title = @"Invoice Name";
		} else if( invoice.type == iBizProjectEstimate ) {
			self.title = @"Estimate Name";
		}
	}
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
	txtField.frame = CGRectMake( txtField.frame.origin.x, txtField.frame.origin.y, txtField.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( project ) {
		txtField.text = project.name;
	} else if( invoice ) {
		txtField.text = invoice.name;
	}
	[txtField becomeFirstResponder];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.txtField = nil;
	[invoice release];
	[project release];
    [super dealloc];
}

- (void) done {
	if( txtField.text.length > 0 ) {
		if( project ) {
			project.name = txtField.text;
		} else if( invoice ) {
			invoice.name = txtField.text;
		}
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Name" message:@"You must enter a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}



@end
