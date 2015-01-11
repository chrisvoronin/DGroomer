//
//  ClientRecoveryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 2/10/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "PSAAppDelegate.h"
#import "PSADataManager.h"
#import "ClientRecoveryViewController.h"


@implementation ClientRecoveryViewController

@synthesize btnAutomatic, btnManual, lbName;

- (void) viewDidLoad {
	NSString *name = [[NSString alloc] initWithFormat:@"Name: %@", [client getClientName]];
	self.lbName.text = name;
	[name release];
}

- (void) viewWillAppear:(BOOL)animated {
	if( [client getPerson] ) {
		[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapRecoveryViewWithClient:client];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	self.btnAutomatic = nil;
	self.btnManual = nil;
	self.lbName = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction) btnAutomaticPressed:(id)sender {
	if( ![[PSADataManager sharedInstance] attemptRecoveryForClient:self.client] ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Find Contact" message:@"The Address Book Contact associated with this Client could not be found, or there is more than one Contact with a similar name. Please select it manually." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
	} else {
		// Swap this VC with the ABPersonVC
		[(PSAAppDelegate*)[[UIApplication sharedApplication] delegate] swapRecoveryViewWithClient:client];
	}
}

- (IBAction) btnManualPressed:(id)sender {
	// Load the PeoplePicker
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.navigationBar.tintColor = [UIColor blackColor];
	picker.peoplePickerDelegate = self;
	[self presentViewController:picker animated:YES completion:nil]; 
	[picker release];
}

#pragma mark -
#pragma mark AddressBook Methods
#pragma mark -

/*
 *	The selection was cancelled
 */ 
- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker { 
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 *	Set our Client data from the contact that was selected
 */
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	// Only store the RecordID of our client
	self.client.personID = ABRecordGetRecordID( person );
	[self.client updateClientNameFromContact];
	// Add to myBusiness Clients group
	if( ABGroupAddMember( [[PSADataManager sharedInstance] addressBookGroup], person, nil) ) {
		ABAddressBookSave( [[PSADataManager sharedInstance] addressBook], nil );
	}
	//
	[[PSADataManager sharedInstance] updateClient:self.client];
	[self dismissViewControllerAnimated:YES completion:nil];
    return NO; 
}

/*
 *	This is never called because we don't drill down into the contact's properties.
 *	It is a required delegate method, however.
 */
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier { 
    return NO; 
}


@end
