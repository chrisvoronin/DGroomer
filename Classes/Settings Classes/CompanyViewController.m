//
//  CompanyViewController.m
//  myBusiness
//
//  Created by David J. Maier on 8/2/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Company.h"
#import "PSADataManager.h"
#import "CompanyViewController.h"


@implementation CompanyViewController

@synthesize name, owner, addr1, addr2, city, state, zip, email, phone, fax;
@synthesize myScrollView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
	// ScrollView size
	[myScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.5)];
	// Nav Bar Title
	self.title = @"COMPANY INFO";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Add Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	// Get the company
	company = [[PSADataManager sharedInstance] getCompany];
	//
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    [singleTap release];
}

- (void)resignOnTap:(UITapGestureRecognizer*)recog
{
    [self.currentResponder resignFirstResponder];
    [myScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void) viewWillAppear:(BOOL)animated {
	if( company != nil ) {
		name.text = company.companyName;
		addr1.text = company.companyAddress1;
		addr2.text = company.companyAddress2;
		city.text = company.companyCity;
		state.text = company.companyState;
		email.text = company.companyEmail;
		owner.text = company.ownerName;
		phone.text = company.companyPhone;
		fax.text = company.companyFax;
		if ( company.companyZipCode != 0 ) {
			NSString *zippy = [[NSString alloc] initWithFormat:@"%li", (long)company.companyZipCode];
			zip.text = zippy;
			[zippy release];
		}	
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[company release];
	[name release];
	[owner release];
	[addr1 release];
	[addr2 release];
	[city release];
	[state release];
	[zip release];
	[email release];
	[phone release];
	[fax release];
	[myScrollView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Action Methods
#pragma mark -
/*
 *
 */
- (void) save {
	// Get rid of the keyboard
	[owner resignFirstResponder];
	[name resignFirstResponder];
	[addr1 resignFirstResponder];
	[addr2 resignFirstResponder];
	[city resignFirstResponder];
	[state resignFirstResponder];
	[zip resignFirstResponder];
	[phone resignFirstResponder];
	[fax resignFirstResponder];
	[email resignFirstResponder];
	// Load data into object
	company.companyName = name.text;
	company.companyAddress1 = addr1.text;
	company.companyAddress2	= addr2.text;
	company.companyCity = city.text;
	company.companyState = state.text;
	company.companyEmail = email.text;
	company.companyZipCode = [zip.text intValue];
	company.companyPhone = phone.text;
	company.companyFax = fax.text;
	company.ownerName = owner.text;
	// Save object to DB
	[[PSADataManager sharedInstance] updateCompany:company];
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if( textField == phone || textField == fax ) {
		NSString *preFormat = [textField.text stringByReplacingCharactersInRange:range withString:string];
		textField.text = [[PSADataManager sharedInstance] formatPhoneNumber:preFormat];
		return NO;
	}
	return YES;
}
 */

- (void) textFieldDidBeginEditing:(UITextField *)textField {
	/*if( myScrollView.frame.size.height != 200 ) {
		myScrollView.frame = CGRectMake( 0, 0, myScrollView.frame.size.width, 200 );
	}
	[myScrollView scrollRectToVisible:textField.frame animated:YES];*/
    self.currentResponder = textField;
    
    
    CGRect textFieldRect = textField.frame;
    CGRect convertRect = [self.view convertRect:textFieldRect fromView:myScrollView];
    int delta = myScrollView.frame.size.height - convertRect.origin.y - convertRect.size.height - 320;
    if(delta < 0){
        [myScrollView setContentOffset:CGPointMake(0, myScrollView.contentOffset.y-delta)];
    }
}

@end
