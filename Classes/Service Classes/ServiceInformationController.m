//
//  ServicesInformation.m
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ColorPickerViewController.h"
#import "PSADataManager.h"
#import "Service.h"
#import "ServiceCostViewController.h"
#import "ServiceGroup.h"
#import "ServiceNameViewController.h"
#import "DurationViewController.h"
#import "ServiceInformationController.h"


@implementation ServiceInformationController

@synthesize myTableView, service;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"ADD SERVICE";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundPurple.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[myTableView setBackgroundColor:bgColor];
	[bgColor release];*/
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {	
	if( service == nil )	service = [[Service alloc] init];
	[myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[formatter release];
	[myTableView release];
	[service release];
    [super dealloc];
}

- (void) save {
	if( service.groupID > -1 ) {
		[[PSADataManager sharedInstance] saveService:service];
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Service" message:@"Please select a Service Group before saving." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}
- (void) cancelService{
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) selectionMadeWithServiceGroup:(ServiceGroup*)theGroup {
	// Record the selection
	service.groupID = theGroup.groupID;
	service.groupName = theGroup.groupDescription;
	// Remove the type table view
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return 4;
	else if( section == 1 ) return 4;
	else if( section == 2 )	return 1;
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"ServiceInfoCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ServiceInfoCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.detailTextLabel.backgroundColor = [UIColor whiteColor];

	switch ( indexPath.section ) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Group";
					cell.detailTextLabel.text = service.groupName;
					break;
				case 1:
					cell.textLabel.text = @"Name";
					cell.detailTextLabel.text = service.serviceName;
					break;
				case 2:
					cell.textLabel.text = @"Color";
					cell.detailTextLabel.text = @"           ";
					cell.detailTextLabel.backgroundColor = service.color;
					break;
				case 3:
					cell.textLabel.text = @"Active";
					cell.detailTextLabel.text = (service.isActive) ? @"Yes" : @"No";
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Price";
					NSString *hourly = (service.serviceIsFlatRate) ? @"" : @"/hr.";
					NSString *price = [[NSString alloc] initWithFormat:@"%@%@", (service.servicePrice != nil) ? [formatter stringFromNumber:service.servicePrice] : [formatter stringFromNumber:[NSNumber numberWithInt:0]], hourly];
					cell.detailTextLabel.text = price;
					[price release];
					break;
				case 1:
					cell.textLabel.text = @"Setup Fee";
					cell.detailTextLabel.text = [formatter stringFromNumber:service.serviceSetupFee];
					break;
				case 2:
					cell.textLabel.text = @"Cost";
					cell.detailTextLabel.text = [formatter stringFromNumber:service.serviceCost];
					break;
				case 3:
					cell.textLabel.text = @"Taxable";
					if( service.taxable ) {
						cell.detailTextLabel.text = @"Yes";
					} else {
						cell.detailTextLabel.text = @"No";
					}
					break;
			}
			break;
		case 2:
			cell.textLabel.text = @"Duration";
			cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringOfHoursAndMinutesForSeconds:service.duration];
			break;
	}
	
	return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( [cell.textLabel.text isEqualToString:@"Color"] ) {
		cell.detailTextLabel.backgroundColor = service.color;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
		case 0:
			switch ( indexPath.row ) {
				case 0: {
					ServiceGroupsTableViewController *cont = [[ServiceGroupsTableViewController alloc] initWithNibName:@"ServiceGroupsTableView" bundle:nil];
					cont.delegate = self;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
					break;
				}
				case 2: {
					ColorPickerViewController *cont = [[ColorPickerViewController alloc] initWithNibName:@"ColorPickerView" bundle:nil];
					cont.service = service;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
					break;
				}
				default: {
					ServiceNameViewController *cont = [[ServiceNameViewController alloc] initWithNibName:@"ServiceNameView" bundle:nil];
					cont.service = service;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
					break;
				}
			}
			break;
		case 1: 
		{
			ServiceCostViewController *cont = [[ServiceCostViewController alloc] initWithNibName:@"ServiceCostView" bundle:nil];
			cont.service = service;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
		case 2: {
			DurationViewController *cont = [[DurationViewController alloc] initWithNibName:@"DurationView" bundle:nil];
			cont.view.backgroundColor = self.myTableView.backgroundColor;
			cont.service = service;
			if( indexPath.row == 2 ) {
				cont.tableIndexEditing = 1;
			} else if( indexPath.row == 3 ) {
				cont.tableIndexEditing = 2;
			}
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
	}
}


@end
