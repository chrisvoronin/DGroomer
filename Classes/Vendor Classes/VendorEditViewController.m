//
//  GroupTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Vendor.h"
#import "VendorEditViewController.h"

@implementation VendorEditViewController

@synthesize vendor;
@synthesize myScrollView, address2, address1, city, contact, email, faxNumber, name, phoneNumber, state, zipcode;

- (void)viewDidLoad {
	self.title = @"Vendor";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	[myScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.5)];
	//
	[super viewDidLoad];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    [singleTap release];
}

- (void)viewWillAppear:(BOOL)animated {	
	if( !vendor ) vendor = [[Vendor alloc] init];
	// Prepopulate
	name.text = vendor.vendorName;
	address1.text = vendor.vendorAddress1;
	address2.text = vendor.vendorAddress2;
	city.text = vendor.vendorCity;
	state.text = vendor.vendorState;
	email.text = vendor.vendorEmail;
	phoneNumber.text = vendor.vendorTelephone;
	faxNumber.text = vendor.vendorFax;
	contact.text = vendor.vendorContact;
	if ( vendor.vendorZipcode != 0 ) {
		NSString *zippy = [[NSString alloc] initWithFormat:@"%d", vendor.vendorZipcode];
		zipcode.text = zippy;
		[zippy release];
	}	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[vendor release];
	self.myScrollView = nil;
	self.address2 = nil;
	self.address1 = nil;
	self.city = nil;
	self.contact = nil;
	self.email = nil;
	self.faxNumber = nil;
	self.name = nil;
	self.phoneNumber = nil;
	self.state = nil;
	self.zipcode = nil;
    [super dealloc];
}

- (void) save {
	if( !(name.text == nil) && ![name.text isEqualToString:@""] ) {
		// Read all the values out of the text fields
		vendor.vendorName = name.text;
		vendor.vendorAddress1 = address1.text;
		vendor.vendorAddress2 = address2.text;
		vendor.vendorCity = city.text;
		vendor.vendorState = state.text;
		vendor.vendorContact = contact.text;
		vendor.vendorEmail = email.text;
		vendor.vendorTelephone = phoneNumber.text;
		vendor.vendorFax = faxNumber.text;
		vendor.vendorZipcode = [zipcode.text integerValue];
		// Save and pop
		[[PSADataManager sharedInstance] saveVendor:vendor];
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Vendor" message:@"A Vendor must have a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	}
}

/*
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField == phoneNumber || textField == faxNumber ) {
		NSString *preFormat = [textField.text stringByReplacingCharactersInRange:range withString:string];
		textField.text = [[PSADataManager sharedInstance] formatPhoneNumber:preFormat];
		return NO;
	}
	return YES;
}
 */
- (void)resignOnTap:(UITapGestureRecognizer*)recog
{
    [self.currentResponder resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
//	if( myScrollView.frame.size.height != 200 ) {
//		myScrollView.frame = CGRectMake( 0, 0, myScrollView.frame.size.width, 200 );
//	}
//	[myScrollView scrollRectToVisible:textField.frame animated:YES];
    self.currentResponder = textField;
    
    
    CGRect textFieldRect = textField.frame;
    CGRect convertRect = [self.view convertRect:textFieldRect fromView:myScrollView];
    int delta = myScrollView.frame.size.height - convertRect.origin.y - convertRect.size.height - 230;
    if(delta < 0){
        [myScrollView setContentOffset:CGPointMake(0, myScrollView.contentOffset.y-delta)];
    }
}

@end
