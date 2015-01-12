//
//  ProductTypeInformationViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductType.h"
#import "PSADataManager.h"
#import "ProductTypeInformationViewController.h"


@implementation ProductTypeInformationViewController

@synthesize type, txtField;

- (void) viewDidLoad {
	self.title = @"Type";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	txtField.frame = CGRectMake( txtField.frame.origin.x, txtField.frame.origin.y, txtField.frame.size.width, 60);
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( type == nil )	type = [[ProductType alloc] init];
	txtField.text = type.typeDescription;
	[txtField becomeFirstResponder];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.txtField = nil;
	[type release];
    [super dealloc];
}

- (void) save {
	if( txtField.text.length > 0 ) {
		type.typeDescription = txtField.text;
		[[PSADataManager sharedInstance] saveProductType:type];
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Product Type" message:@"You must enter a name for this type." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

-(void) cancelAdd {
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
