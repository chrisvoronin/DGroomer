//
//  VendorViewController.m
//  myBusiness
//
//  Created by David J. Maier on 7/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "Vendor.h"
#import "VendorEditViewController.h"
#import "VendorViewController.h"
#import "VendorTableViewController.h"


@implementation VendorTableViewController

@synthesize delegate, myTableView, vendors;


- (void)viewDidLoad {
	if( !delegate ) {
		delegate = self;
	}
	self.title = @"VENDORS";
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addVendor)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	vendorToDelete = nil;
	//
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {	
	if( vendors )	[vendors release];
	vendors = [[PSADataManager sharedInstance] getVendors];
	[myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.myTableView = nil;
	[vendors release];
	[super dealloc];
}

- (void) addVendor {
	VendorEditViewController *cont = [[VendorEditViewController alloc] initWithNibName:@"VendorEditView" bundle:nil];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

#pragma mark -
#pragma mark PSAVendorTableDelegate Methods
#pragma mark -

- (void) selectionMadeWithVendor:(Vendor*)theVendor {
	VendorViewController *vend = [[VendorViewController alloc] initWithNibName:@"VendorView" bundle:nil];
	vend.vendor = theVendor;
	[self.navigationController pushViewController:vend animated:YES];
	[vend release];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -
/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Clicked the Delete button
	if( buttonIndex == 0 ) {
		if( vendorToDelete != nil ) {
			// Get the Product we're deleting
			Vendor *tmp = [vendors objectAtIndex:vendorToDelete.row];
			if( tmp ){
				[[PSADataManager sharedInstance] removeVendor:tmp];
			}
			// Release and repopulate our dictionary
			[vendors release];
			vendors = [[PSADataManager sharedInstance] getVendors];
			
			// Animate the deletion from the table.
			[myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:vendorToDelete] withRowAnimation:UITableViewRowAnimationTop];
		}		
	}
	[vendorToDelete release];
	vendorToDelete = nil;
}

- (void) cancelEdit
{
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource methods
#pragma mark -
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"VendorCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VendorCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if( delegate == self ) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
    }
	
	Vendor *tmp = [vendors objectAtIndex:indexPath.row];
	if( tmp ) {
		if( tmp.vendorName ) {
			cell.textLabel.text = tmp.vendorName;
		} else {
			cell.textLabel.text = @"No Name";
		}
		if( tmp.vendorTelephone && tmp.vendorContact ) {
			NSString *phone = [[NSString alloc] initWithFormat:@"#: %@ Contact: %@", tmp.vendorTelephone, tmp.vendorContact];
			cell.detailTextLabel.text = phone;
			[phone release];
		} else if( tmp.vendorTelephone ) {
			NSString *phone = [[NSString alloc] initWithFormat:@"#: %@", tmp.vendorTelephone];
			cell.detailTextLabel.text = phone;
			[phone release];
		} else if( tmp.vendorContact ) {
			NSString *name = [[NSString alloc] initWithFormat:@"Contact: %@", tmp.vendorContact];
			cell.detailTextLabel.text = name;
			[name release];
		} else {
			cell.detailTextLabel.text = @"No Contact Information";
		}
		
	}
	
	return cell;
}

// The table has one row for each possible type.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return vendors.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Call the delegate method
	[self.delegate selectionMadeWithVendor:[vendors objectAtIndex:indexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Display alert
		vendorToDelete = [indexPath retain];
        // Display alert
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This will delete the Vendor!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
    }
}



@end

