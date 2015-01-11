//
//  AddClientContactController.m
//  myBusiness
//
//  Created by David J. Maier on 6/5/09.
//  Modified by David J. Maier on 10/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "ClientTableViewController.h"
#import "PSADataManager.h"
#import "AddClientContactController.h"


@implementation AddClientContactController

@synthesize myTableView;


//	Setup some elements and properties before the view displays
- (void)viewDidLoad {
	// Set the navigation bar title
	self.title = @"Add Client";
	// Set the background color to a nice yellow image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGold.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[myTableView setBackgroundColor:bgColor];
	[bgColor release];
	//
    [super viewDidLoad];
}

//	Bad memories, clear out unnecessary datas
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

//	Cleanup
- (void)dealloc {
	self.myTableView = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	2 sections, one for the import button (in header), the other for all the information
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv {
    return 2;
}

/*
 *	1 row for each section
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

/*
 *	Return the strings for section titles
 */
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( section == 0 )		return @"Import";
	else if( section == 1 )	return @"Add";
	return nil;
}

/*
 *	Create or modify a cell and return it
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"TypeCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TypeCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	if( indexPath.section == 0 ) {
		cell.textLabel.text = @"From Contacts";
	} else if( indexPath.section == 1 ) {
		cell.textLabel.text = @"New Client Contact";
	}
	 
	return cell;
}

/*
 *	When a row is selected go to the corresponding data entry view
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( indexPath.section == 0 ) {
		ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
		picker.navigationBar.tintColor = [UIColor blackColor];
		picker.peoplePickerDelegate = self;
        //picker.delegate = self;
        
		[self presentViewController:picker animated:YES completion:nil];
        //presentViewController(picker, animated: true, completion: nil);
		[picker release];
	} else if( indexPath.section == 1 ) {
		ABNewPersonViewController *new = [[ABNewPersonViewController alloc] init];
		new.addressBook = [[PSADataManager sharedInstance] addressBook];
		new.parentGroup = [[PSADataManager sharedInstance] addressBookGroup];
		new.newPersonViewDelegate = self;
		new.view.backgroundColor = self.myTableView.backgroundColor;
		for( UIView *sub in new.view.subviews ) {
			sub.backgroundColor = self.myTableView.backgroundColor;
		}
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:new];
		nav.navigationBar.tintColor = [UIColor blackColor];
		[self presentViewController:nav animated:YES completion:nil];
		[new release];
		[nav release];
	}
}

#pragma mark -
#pragma mark AddressBook Methods
#pragma mark -


// Called after a person has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    Client *newClient = [[Client alloc] init];
    // Erase the client data
    [newClient clear];
    // Only store the RecordID of our client
    newClient.personID = ABRecordGetRecordID( person );
    [newClient updateClientNameFromContact];
    // Add to myBusiness Clients group
    if( ABGroupAddMember( [[PSADataManager sharedInstance] addressBookGroup], person, nil) ) {
        ABAddressBookSave( [[PSADataManager sharedInstance] addressBook], nil );
    }
    //
    [[PSADataManager sharedInstance] saveNewClient:newClient];
    [newClient release];
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

// Called after a property has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
}

/*
 *	The selection was cancelled
 */ 
- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {

    [self dismissViewControllerAnimated:YES completion:nil];
}

/*nn
 *	Set our Client data from the contact that was selected
 */
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    Client *newClient = [[Client alloc] init];
    // Erase the client data
    [newClient clear];
    // Only store the RecordID of our client
    newClient.personID = ABRecordGetRecordID( person );
    [newClient updateClientNameFromContact];
    // Add to myBusiness Clients group
    if( ABGroupAddMember( [[PSADataManager sharedInstance] addressBookGroup], person, nil) ) {
        ABAddressBookSave( [[PSADataManager sharedInstance] addressBook], nil );
    }
    //
    [[PSADataManager sharedInstance] saveNewClient:newClient];
    [newClient release];
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

/*
 *	When the ABNewPersonViewController returns, this is called.
 */
- (void) newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
	Client *newClient = [[Client alloc] init];
	// If there was a person created
	[newClient clear];
	if( person != nil ){
		// Save the recordID to our DB
		newClient.personID = ABRecordGetRecordID( person );
		[newClient updateClientNameFromContact];
		[[PSADataManager sharedInstance] saveNewClient:newClient];
	}
	[newClient release];
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
