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
#import "BatchOutViewController.h"

@implementation SettingsViewController

@synthesize settingsTable, bBatchOut, isShowDatePicker, strDate;


- (void)viewDidLoad {
	self.title = @"SETTINGS";
	// Set the background
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundOrange.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[settingsTable setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    bBatchOut = NO;
    isShowDatePicker = NO;
    if(!strDate || strDate.length<1)
        strDate = @"6:00 PM";
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
    [_batchBtn release];
    [_dateCell release];
    [_datePicker release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	1 Section for Settings, 1 for other editable datas
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

/*
 *	We have 6 rows (4 active... no emails yet)
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==2)
        return 216;
    else
        return 44;
}
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if( section == 0){
        if(!bBatchOut)
            return 1;
        else{
            if(isShowDatePicker)
                return 3;
            else
                return 2;
        }
    }
	else if( section == 1 )		return 6;
	else if( section == 2 )	return 4;
	return 0;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify;
    if (indexPath.section==0) {
        switch (indexPath.row) {
            case 0:
                identify = @"BatchOutTableViewCell";
                break;
            case 1:
                identify = @"SettingsCell";
                break;
            case 2:
                identify = @"DatePickerTableViewCell";
                break;
        }
        
    } else{
        identify = @"SettingsCell";
    }
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identify];
    if( cell == nil ) {
        if (indexPath.section==0 && indexPath.row==0) {
            [[NSBundle mainBundle] loadNibNamed:identify owner:self options:nil];
            [self.batchBtn.swBatchOut setOn:bBatchOut];
            cell = self.batchBtn;
            self.batchBtn = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryNone;
            }
        else if(indexPath.section==0 && indexPath.row==1){
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if(indexPath.section==0 && indexPath.row==2){
            [[NSBundle mainBundle] loadNibNamed:identify owner:self options:nil];
            cell = self.dateCell;
            self.dateCell = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingsCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    if( indexPath.section == 0) {
        switch(indexPath.row) {
            case 1:
            {
                cell.textLabel.text = @"Time";
                cell.detailTextLabel.text = self.strDate;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            /*case 2:{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm a"];
                [formatter release];
                NSDate *date1 = [formatter dateFromString:self.strDate];
                [self.datePicker setDate:[formatter dateFromString:self.strDate]];
            }
                break;*/
            //cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
	else if( indexPath.section == 1 ) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Company Information";
                cell.detailTextLabel.text = @"";
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
	else if( indexPath.section == 2 ) {
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
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 1:
            {
                isShowDatePicker = (isShowDatePicker)?NO:YES;
                [self.settingsTable reloadData];
                /*BatchOutViewController *BatchControl = [[BatchOutViewController alloc] initWithNibName:@"BatchOutViewController" bundle:nil];
                
                BatchControl.lblTime.text = @"";
                [self.navigationController pushViewController:BatchControl animated:YES];
                
                [BatchControl release];*/
            }
                break;
                
            default:
                break;
        }
    }
	if( indexPath.section == 1 ) {
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
	else if( indexPath.section == 2 ) {
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
- (IBAction)switchChanged:(id)sender {
    if([sender isOn]){
        bBatchOut = YES;
    } else{
        bBatchOut = NO;
    }
    [self.settingsTable reloadData];
}

- (IBAction)datePickerChanged:(id)sender {
     NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.settingsTable cellForRowAtIndexPath:targetedCellIndexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    self.strDate = [formatter stringFromDate:self.datePicker.date];
    [formatter release];
    cell.detailTextLabel.text = self.strDate;
}




@end
