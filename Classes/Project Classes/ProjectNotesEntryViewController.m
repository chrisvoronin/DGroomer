//
//  ProjectNotesEntryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/19/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectNotesEntryViewController.h"


@implementation ProjectNotesEntryViewController

@synthesize invoice, project, tvText;

- (void) viewDidLoad {
	self.title = @"Notes";
	// Background
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	//
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( project ) {
		tvText.text = project.notes;
	} else if( invoice ) {
		tvText.text = invoice.notes;
	}
	[tvText becomeFirstResponder];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.tvText = nil;
	[invoice release];
	[project release];
    [super dealloc];
}

- (void) done {
	[tvText resignFirstResponder];
	if( project ) {
		project.notes = tvText.text;
	} else if( invoice ) {
		invoice.notes = tvText.text;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
