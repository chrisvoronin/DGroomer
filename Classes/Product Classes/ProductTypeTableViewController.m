//
//  GroupTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductTypeInformationViewController.h"
#import "ProductType.h"
#import "PSADataManager.h"
#import "ProductTypeTableViewController.h"


@implementation ProductTypeTableViewController

@synthesize myTableView, typeDelegate;

- (void) viewDidLoad {
	if( !typeDelegate ) {
		typeDelegate = self;
	}
	// Set the navigation bar title
	self.title = @"Product Types";
	typeToDelete = nil;
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProductType)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	if( types != nil )	[types release];
	types = [[PSADataManager sharedInstance] getProductTypes];	
	[myTableView reloadData];
}


- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.myTableView = nil;
	[types release];
    [super dealloc];
}

- (void) addProductType {
	// Go to Product Type editing view
	ProductTypeInformationViewController *cont = [[ProductTypeInformationViewController alloc] initWithNibName:@"ProductTypeTextFieldView" bundle:nil];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) selectionMadeWithProductType:(ProductType*)theType {
	// Don't edit the default (id=0)
	if( theType.typeID != 0 ) {
		// Go to Product Type editing view
		ProductTypeInformationViewController *cont = [[ProductTypeInformationViewController alloc] initWithNibName:@"ProductTypeTextFieldView" bundle:nil];
		cont.type = theType;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	}
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -
/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Clicked the Delete button
	if( buttonIndex == 0 ) {
		if( typeToDelete != nil ) {
			// Get the Product we're deleting
			ProductType *tmpType = [types objectAtIndex:typeToDelete.row];
			if( tmpType ){
				[[PSADataManager sharedInstance] removeProductType:tmpType];
			}
			// Release and repopulate our dictionary
			[types release];
			types = [[PSADataManager sharedInstance] getProductTypes];
			
			// Animate the deletion from the table.
			[myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:typeToDelete] withRowAnimation:UITableViewRowAnimationTop];
		}		
	}
	[typeToDelete release];
	typeToDelete = nil;
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	// Just a one
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	// Number of products for each group
	return types.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"ProductCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if( typeDelegate == self ) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
    }
	
	ProductType *type = [types objectAtIndex:indexPath.row];
	if( type ) {
		cell.textLabel.text = type.typeDescription;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Report
	[self.typeDelegate selectionMadeWithProductType:[types objectAtIndex:indexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	ProductType *type = [types objectAtIndex:indexPath.row];
	if( type ) {
		if( type.typeID == 0 ) {
			// Our default type... no deletes
			return UITableViewCellEditingStyleNone;
		}
	}
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        typeToDelete = [indexPath retain];
        // Display alert
		NSString *msg = [[NSString alloc] initWithFormat:@"This will delete this Product Type from %@. Any products under this type will have their type set to 'Untyped'.", APPLICATION_NAME];
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[msg release];
		[alert showInView:self.view];	
		[alert release];
    }
}

@end
