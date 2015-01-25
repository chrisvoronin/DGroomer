//
//  SettingsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 7/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ClientTableViewController.h"
#import "CommissionTaxViewController.h"
#import "CompanyViewController.h"
#import "CreditCardSettingsViewController.h"
#import "EmailSettingsViewController.h"
#import "ProductTypeTableViewController.h"
#import "ServiceGroupsTableViewController.h"
#import "VendorTableViewController.h"
#import "ViewOptionsViewController.h"
#import "WorkHoursViewController.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize settingsTable;


- (void)viewDidLoad {
	self.title = @"SETTINGS";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[settingsTable setBackgroundColor:bgColor];
	[bgColor release];*/
	//
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[settingsTable release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	1 Section for Settings, 1 for other editable datas
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/*
 *	We have 6 rows (4 active... no emails yet)
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )		return 6;
	else if( section == 1 )	return 4;
	return 0;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	if( indexPath.section == 0 ) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Company Information";
				break;
			case 1:
				cell.textLabel.text = @"Credit Card Processing";
				break;
			case 2:
				cell.textLabel.text = @"Alerts";
				break;
			case 3:
				cell.textLabel.text = @"Sales Tax";
				break;
			case 4:
				cell.textLabel.text = @"View Options";
				break;
			case 5:
				cell.textLabel.text = @"Working Hours";
				break;
		}
	}
	else if( indexPath.section == 1 ) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Clients";
				break;
			case 1:
				cell.textLabel.text = @"Product Types";
				break;
			case 2:
				cell.textLabel.text = @"Service Groups";
				break;
			case 3:
				cell.textLabel.text = @"Vendors";
				break;
		}
	}
	
	
	return cell;
}

/*
 *	Loads and pushes the editing views onto the navigation stack
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Go to selection
	if( indexPath.section == 0 ) {
		switch (indexPath.row) {
			case 0: {
				CompanyViewController *companyControl = [[CompanyViewController alloc] initWithNibName:@"CompanyView" bundle:nil];
				[self.navigationController pushViewController:companyControl animated:YES];
				[companyControl release];
				break;
			}
			case 1: {
				CreditCardSettingsViewController *creditControl = [[CreditCardSettingsViewController alloc] initWithNibName:@"CreditCardSettingsView" bundle:nil];
				[self.navigationController pushViewController:creditControl animated:YES];
				creditControl.view.backgroundColor = self.settingsTable.backgroundColor;
				[creditControl release];
				break;
			}
			case 2: {
				EmailSettingsViewController *emailControl = [[EmailSettingsViewController alloc] initWithNibName:@"EmailSettingsView" bundle:nil];
				[self.navigationController pushViewController:emailControl animated:YES];
				[emailControl release];
				break;
			}
			case 3: {
				CommissionTaxViewController *rateControl = [[CommissionTaxViewController alloc] initWithNibName:@"CommissionTaxView" bundle:nil];
				[self.navigationController pushViewController:rateControl animated:YES];
				[rateControl release];
				break;
			}
			case 4: {
				ViewOptionsViewController *viewOptions = [[ViewOptionsViewController alloc] initWithNibName:@"ViewOptionsView" bundle:nil];
				[self.navigationController pushViewController:viewOptions animated:YES];
				[viewOptions release];
				break;
			}
			case 5: {
				WorkHoursViewController *timeControl = [[WorkHoursViewController alloc] initWithNibName:@"WorkHoursView" bundle:nil];
				[self.navigationController pushViewController:timeControl animated:YES];
				[timeControl release];
				break;
			}
		}
	}
	else if( indexPath.section == 1 ) {
		switch (indexPath.row) {
			case 0: {
				// Client Table
				ClientTableViewController *vc = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
				vc.isSwappingContacts = YES;
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
				break;
			}
			case 1: {
				// Product Group Table
				ProductTypeTableViewController *vc = [[ProductTypeTableViewController alloc] initWithNibName:@"ProductTypeTableView" bundle:nil];
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
				break;
			}
			case 2: {
				// Service Group Table
				ServiceGroupsTableViewController *sgvc = [[ServiceGroupsTableViewController alloc] initWithNibName:@"ServiceGroupsTableView" bundle:nil];
				[self.navigationController pushViewController:sgvc animated:YES];
				[sgvc release];
				break;
			}
			case 3: {
				// Vendor Table
				VendorTableViewController *vend = [[VendorTableViewController alloc] initWithNibName:@"VendorTableView" bundle:nil];
				[self.navigationController pushViewController:vend animated:YES];
				[vend release];
				break;
			}
		}
	}
	
}





@end
