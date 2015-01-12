//
//  ReportsMenuViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductsTableViewController.h"
#import "Report.h"
#import "ReportsDateRangeViewController.h"
#import "ReportsMenuViewController.h"


@implementation ReportsMenuViewController

@synthesize tblReports;


- (void)viewDidLoad {
	self.title = @"Reports";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundAquamarine.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblReports setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblReports = nil;
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
#ifdef PROJECT_NOT_INCLUDED
	return 2;
#else
	if( section == 2 )	return 3;
	return 2;
#endif
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"RegisterCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegisterCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Closeout History";
			} else {
				cell.textLabel.text = @"Closeout Totals (Consolidated)";
			}
			break;
		case 1:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Product History";
			} else {
				cell.textLabel.text = @"Product Inventory";
			}
			break;
		case 2:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Credit Payments History";
			} else if( indexPath.row == 1 ) {
#ifdef PROJECT_NOT_INCLUDED
				cell.textLabel.text = @"Transaction History";	
#else
				cell.textLabel.text = @"Invoice History";		
#endif
			} else {
				cell.textLabel.text = @"Transaction History";
			}
			break;
	}
	
	return cell;
}

/*
 *	
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if( indexPath.section == 1 && indexPath.row == 1 ) {
		ProductsTableViewController *productVC = [[ProductsTableViewController alloc] initWithNibName:@"ProductsTableView" bundle:nil];
		productVC.isInventoryReport = YES;
		[self.navigationController pushViewController:productVC animated:YES];
		[productVC release];
	} else {
		// Create the Report
		Report *theReport = [[Report alloc] init];
		ReportsDateRangeViewController *cont = [[ReportsDateRangeViewController alloc] initWithNibName:@"ReportsDateRangeView" bundle:nil];
		// Set Report type
		switch ( indexPath.section ) {
			case 0:
				if( indexPath.row == 0 ) {
					theReport.type = PSAReportTypeCloseoutHistory;
				} else {
					theReport.type = PSAReportTypeConsolidatedCloseout;
				}
				break;
			case 1:
				if( indexPath.row == 0 ) {
					theReport.type = PSAReportTypeProductHistory;
				} else {
					theReport.type = PSAReportTypeProductInventory;
				}
				break;
			case 2: {
				if( indexPath.row == 0 ) {
					theReport.type = PSAReportTypeCreditPaymentsHistory;
				} else if( indexPath.row == 1 ) {
#ifdef PROJECT_NOT_INCLUDED
					theReport.type = PSAReportTypeTransactionHistory;
#else
					theReport.type = PSAReportTypeInvoiceHistory;
#endif
				} else {
					theReport.type = PSAReportTypeTransactionHistory;
				}
				break;
			}
		}
		// Go!
		cont.report = theReport;
		[theReport release];
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	}
}



@end
