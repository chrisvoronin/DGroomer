//
//  ProjectPaymentsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/26/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectEstimateInvoiceViewController.h"
#import "ProjectInvoice.h"
#import "Transaction.h"
#import "TransactionViewController.h"
#import "ProjectEstimatesViewController.h"


@implementation ProjectEstimatesViewController

@synthesize cellPayment, project, tblPayments;

- (void) viewDidLoad {
	//
	self.title = @"Estimates";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblPayments setBackgroundColor:bgColor];
	[bgColor release];
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	//
	[tblPayments reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	self.tblPayments = nil;
	[project release];
    [super dealloc];
}

- (void) add {
	ProjectInvoice *inv = [[ProjectInvoice alloc] init];
	inv.projectID = project.projectID;
	inv.type = iBizProjectEstimate;
	NSString *name = [[NSString alloc] initWithFormat:@"%@ Estimate %d", project.name, [[project.payments objectForKey:[project getKeyForEstimates]] count]+1];
	inv.name = name;
	[name release];
	// Load the products and services	
	[inv importProducts:project.products];
	[inv importServices:project.services];			
	// Create and display
	ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
	cont.invoice = inv;
	cont.project = project;
	[inv release];
	cont.isModal = YES;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	NSArray *tmp = nil;
	if( section == 0 ) {
		tmp = [project.payments objectForKey:[project getKeyForEstimates]];
	}
	if( tmp.count > 0 ) {
		return tmp.count;
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ( section ) {
		case 0:		return [project getKeyForEstimates];
		case 1:		return @"Total";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ProjectPaymentCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		cell = cellPayment;
		self.cellPayment = nil;
	}
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
	
	NSArray *array = nil;
	if( indexPath.section == 0 ) {
		// Estimates
		array = [project.payments objectForKey:[project getKeyForEstimates]];
		if( array.count == 0 ) {
			NSString *tit = [[NSString alloc] initWithFormat:@"No %@", [project getKeyForEstimates]];
			lbName.text = tit;
			[tit release];
			lbTotal.text = @"";
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			ProjectInvoice *tmp = [array objectAtIndex:indexPath.row];
			if( tmp ) {
				lbName.text = tmp.name;
				lbTotal.text = [formatter stringFromNumber:tmp.totalForTable];
				
				if( tmp.datePaid ) {
					lbTotal.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
				} else if( [[NSDate date] timeIntervalSinceDate:tmp.dateDue] > 0 ) {
					lbTotal.textColor = [UIColor redColor];
				} else {
					lbTotal.textColor = [UIColor blackColor];
				}
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	} else if( indexPath.section == 1 ) {
		// Total
		lbName.text = @"Total";
		lbTotal.text = [formatter stringFromNumber:[[project getEstimateTotals] objectAtIndex:1]];
		lbTotal.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	NSArray *array = nil;
	if( indexPath.section == 0 ) {
		array = [project.payments objectForKey:[project getKeyForEstimates]];
	}
	if( array.count > 0 && indexPath.section != 1 ) {
		ProjectInvoice *tmp = [array objectAtIndex:indexPath.row];
		if( tmp ) {
			ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
			cont.isModal = NO;			
			cont.project = project;
			cont.invoice = tmp;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}


@end
