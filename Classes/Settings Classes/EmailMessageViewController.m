//
//  EmailMessageViewController.m
//  myBusiness
//
//  Created by David J. Maier on 2/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Email.h"
#import "PSADataManager.h"
#import "EmailMessageViewController.h"


@implementation EmailMessageViewController

@synthesize email, btnInsertField, scrollView, swBccSelf, txtMessage, txtSubject;

- (void)viewDidLoad {
	// Set the background
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Add Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	// Set the font of the UITextView
	txtMessage.font = txtSubject.font;
	//
	txtSubject.frame = CGRectMake( txtSubject.frame.origin.x, txtSubject.frame.origin.y, txtSubject.frame.size.width, 36);
	[scrollView setContentSize:CGSizeMake( scrollView.frame.size.width, scrollView.frame.size.height )];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !email ) {
		email = [[Email alloc] init];
	}
	swBccSelf.on = email.bccCompany;
	txtSubject.text = email.subject;
	txtMessage.text = email.message;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[email release];
	self.btnInsertField = nil;
	self.scrollView = nil;
	self.swBccSelf = nil;
	self.txtMessage = nil;
	self.txtSubject = nil;
    [super dealloc];
}

- (void) save {
	email.bccCompany = swBccSelf.on;
	email.subject = txtSubject.text;
	email.message = txtMessage.text;
	[[PSADataManager sharedInstance] saveEmail:email];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Insert Field Methods
#pragma mark -
- (IBAction) btnInsertFieldTouchUp:(id)sender {
	// Show action sheet to select field to insert
	if( email.type == PSAEmailTypeAnniversary ) {
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Insert a field into your email message..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Client Name", @"Anniversary Date", nil];
		[alert showInView:self.view];	
		[alert release];
	} else if( email.type == PSAEmailTypeBirthday ) {
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Insert a field into your email message..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Client Name", @"Birthdate", nil];
		[alert showInView:self.view];	
		[alert release];
	} else if( email.type == PSAEmailTypeAppointmentReminder ) {
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Insert a field into your email message..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Client Name", @"Appointment Date", @"Appointment Time", @"Service Name", nil];
		[alert showInView:self.view];	
		[alert release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( email.type == PSAEmailTypeAnniversary ) {
		if( buttonIndex == 0 ) {
			// Client Name
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<CLIENT>>"];
		} else if( buttonIndex == 1 ) {
			// Anniversary Date
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<ANNIVERSARY>>"];
		}
	} else if( email.type == PSAEmailTypeBirthday ) {
		if( buttonIndex == 0 ) {
			// Client Name
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<CLIENT>>"];
		} else if( buttonIndex == 1 ) {
			// Birthdate
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<BIRTHDATE>>"];
		}
	} else if( email.type == PSAEmailTypeAppointmentReminder ) {
		if( buttonIndex == 0 ) {
			// Client Name
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<CLIENT>>"];
		} else if( buttonIndex == 1 ) {
			// Appt. Date
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<APPT_DATE>>"];
		} else if( buttonIndex == 2 ) {
			// Appt. Time
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<APPT_TIME>>"];
		} else if( buttonIndex == 3 ) {
			// Service Name
			txtMessage.text = [txtMessage.text stringByReplacingCharactersInRange:txtMessage.selectedRange withString:@"<<SERVICE>>"];
		}
	}
}

#pragma mark -
#pragma mark Delegate Methods
#pragma mark -
- (void) textFieldDidBeginEditing:(UITextField *)textField {
	if( scrollView.frame.size.height != 200 ) {
		scrollView.frame = CGRectMake( 0, 0, scrollView.frame.size.width, 200 );
	}
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
	if( scrollView.frame.size.height != 200 ) {
		scrollView.frame = CGRectMake( 0, 0, scrollView.frame.size.width, 200 );
	}	
}


@end
