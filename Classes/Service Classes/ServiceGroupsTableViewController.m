//
//  ServiceGroupsTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/10/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import "ServiceGroup.h";
#import "ServiceGroupViewController.h"
#import "ServiceGroupsTableViewController.h"


@implementation ServiceGroupsTableViewController

@synthesize delegate, myTableView;

- (void) viewDidLoad {
	if( !delegate ) {
		delegate = self;
	}
	// Set the navigation bar title
	self.title = @"Service Groups";
	//typeToDelete = nil;
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServiceGroup)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( groups != nil )	[groups release];
	groups = [[PSADataManager sharedInstance] getServiceGroups];	
	[myTableView reloadData];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void) dealloc {
	self.myTableView = nil;
	[groups release];
    [super dealloc];
}

- (void) addServiceGroup {
	ServiceGroupViewController *cont = [[ServiceGroupViewController alloc] initWithNibName:@"ServiceGroupView" bundle:nil];
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

- (void) selectionMadeWithServiceGroup:(ServiceGroup*)theGroup {
	// Don't edit the default (id=0)
	if( theGroup.groupID != 0 ) {
		// Go to Product Type editing view
		ServiceGroupViewController *cont = [[ServiceGroupViewController alloc] initWithNibName:@"ServiceGroupView" bundle:nil];
		cont.group = theGroup;
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
		if( groupToDelete != nil ) {
			// Get the Product we're deleting
			ServiceGroup *tmpType = [groups objectAtIndex:groupToDelete.row];
			if( tmpType ){
				[[PSADataManager sharedInstance] removeServiceGroup:tmpType];
			}
			// Release and repopulate our dictionary
			[groups release];
			groups = [[PSADataManager sharedInstance] getServiceGroups];
			
			// Animate the deletion from the table.
			[myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:groupToDelete] withRowAnimation:UITableViewRowAnimationTop];
		}		
	}
	[groupToDelete release];
	groupToDelete = nil;
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
	return groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"ProductCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if( delegate == self ) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
    }
	
	ServiceGroup *grp = [groups objectAtIndex:indexPath.row];
	if( grp && grp.groupDescription ) {
		cell.textLabel.text = grp.groupDescription;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Report
	[self.delegate selectionMadeWithServiceGroup:[groups objectAtIndex:indexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	ServiceGroup *grp = [groups objectAtIndex:indexPath.row];
	if( grp ) {
		if( grp.groupID == 0 ) {
			// Our default group... no deletes
			return UITableViewCellEditingStyleNone;
		}
	}
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        groupToDelete = [indexPath retain];
        // Display alert
		NSString *myTitle = [[NSString alloc] initWithFormat:@"This will delete this Service Group from %@. Any services under this group will have their group set to 'Ungrouped'.", APPLICATION_NAME];
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:myTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[myTitle release];
		[alert showInView:self.view];	
		[alert release];
    }
}

@end
