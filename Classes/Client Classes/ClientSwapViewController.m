//
//  ClientSwapViewController.m
//  PSA
//
//  Created by David J. Maier on 2/10/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "PSAAppDelegate.h"
#import "PSADataManager.h"
#import "ClientSwapViewController.h"


@implementation ClientSwapViewController

@synthesize btnManual, lbName, lbNameContact;

- (void) viewWillAppear:(BOOL)animated {
	NSString *name = [[NSString alloc] initWithFormat:@"First: %@  Last: %@", (client.firstName) ? client.firstName : @"None", (client.lastName) ? client.lastName : @"None"];
	self.lbName.text = name;
	[name release];
	if( [client getPerson] ) {
		NSString *name = [[NSString alloc] initWithFormat:@"%@", [client getClientName]];
		self.lbNameContact.text = name;
		[name release];
	} else {
		NSString *name = [[NSString alloc] initWithString:@"A contact can't be found for this client!"];
		self.lbNameContact.text = name;
		[name release];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	self.btnManual = nil;
	self.lbName = nil;
	self.lbNameContact = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction) btnManualPressed:(id)sender {
	// Load the PeoplePicker
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	//picker.navigationBar.tintColor = [UIColor blackColor];
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
	[self.client updatePerson];
	[self.client updateClientNameFromContact];
	// Add to PSA Clients group
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
