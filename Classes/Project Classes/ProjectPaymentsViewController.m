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
#import "ProjectPaymentsViewController.h"


@implementation ProjectPaymentsViewController

@synthesize cellPayment, project, tblPayments;

- (void) viewDidLoad {
	//
	self.title = @"Invoices/Payments";
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
	// Returning from adding a Non-Invoiced Transaction?
	if( transaction ) {
		NSMutableArray *array = [project.payments objectForKey:[project getKeyForTransactions]];
		if( transaction.transactionID > -1 && ![array containsObject:transaction] ) {
			[array insertObject:transaction atIndex:0];
			[transaction release];
			transaction = nil;
		}
	}
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
	// Query User
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invoice", @"Non-Invoiced Transaction", nil];
	[action showInView:self.view];
	[action release];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Method
#pragma mark -
/*
 *	Creates the ProjectInvoice and displays it.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex != 2 ) {
		if( buttonIndex == 1 ) {
			// Create a Transaction, setting the projectID and Client
			transaction = [[Transaction alloc] init];
			transaction.client = project.client;
			transaction.isHydrated = YES;
			transaction.projectID = project.projectID;
			// Single (new) transaction
			TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
			cont.transaction = transaction;
			UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
			cont.navigationItem.leftBarButtonItem = cancel;
			[cancel release];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
			nav.navigationBar.tintColor = [UIColor blackColor];
			[self presentViewController:nav animated:YES completion:nil];
			[cont release];
			[nav release];
			// Don't release yet, hang onto the Transaction
			//[tranny release];
		} else {
			ProjectInvoice *inv = [[ProjectInvoice alloc] init];
			inv.projectID = project.projectID;
			inv.type = iBizProjectInvoice;
			NSString *name2 = [[NSString alloc] initWithFormat:@"%@ Invoice %d", project.name, [[project.payments objectForKey:[project getKeyForInvoices]] count]+1];
			inv.name = name2;
			[name2 release];

			[inv importProducts:project.products];
			[inv importServices:project.services];			
			
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
	}
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	NSArray *tmp = nil;
	if( section == 0 ) {
		tmp = [project.payments objectForKey:[project getKeyForInvoices]];
	} else if( section == 1 ) {
		tmp = [project.payments objectForKey:[project getKeyForTransactions]];
	}
	if( tmp.count > 0 ) {
		return tmp.count;
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ( section ) {
		case 0:		return [project getKeyForInvoices];
		case 1:		return [project getKeyForTransactions];
		case 2:		return @"Total";
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
	
	lbTotal.textColor = [UIColor blackColor];
	
	NSArray *array = nil;
	if( indexPath.section == 0 ) {
		// Invoices
		array = [project.payments objectForKey:[project getKeyForInvoices]];
		if( array.count == 0 ) {
			NSString *tit = [[NSString alloc] initWithFormat:@"No %@", [project getKeyForInvoices]];
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
				}
				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	} else if( indexPath.section == 1 ) {
		// Non-Invoiced Transactions		
		array = [project.payments objectForKey:[project getKeyForTransactions]];
		
		if( array.count == 0 ) {
			NSString *tit = [[NSString alloc] initWithFormat:@"No %@", [project getKeyForTransactions]];
			lbName.text = tit;
			[tit release];
			lbTotal.text = @"";
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			Transaction *tmp = [array objectAtIndex:indexPath.row];
			if( tmp.dateVoided ) {
				NSString *date = [[NSString alloc] initWithFormat:@"VOID - %@ %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateVoided withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:tmp.dateVoided withFormat:NSDateFormatterShortStyle]];
				lbName.text = date;
				[date release];
			} else if( tmp.dateClosed ) {
				lbTotal.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
				NSString *date = [[NSString alloc] initWithFormat:@"CLOSED - %@ %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateClosed withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:tmp.dateClosed withFormat:NSDateFormatterShortStyle]];
				lbName.text = date;
				[date release];
			} else {
				NSString *date = [[NSString alloc] initWithFormat:@"OPEN - %@ %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateOpened withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:tmp.dateOpened withFormat:NSDateFormatterShortStyle]];
				lbName.text = date;
				[date release];
			}
			lbTotal.text = [formatter stringFromNumber:tmp.totalForTable];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else if( indexPath.section == 2 ) {
		// Total
		lbName.text = @"Total";
		lbTotal.text = [formatter stringFromNumber:[project getInvoiceTotals]];
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
		array = [project.payments objectForKey:[project getKeyForInvoices]];
	} else if( indexPath.section == 1 ) {
		array = [project.payments objectForKey:[project getKeyForTransactions]];
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
	} else if( array.count > 0 && indexPath.section == 1 ) {
		Transaction *tmp = [array objectAtIndex:indexPath.row];
		if( tmp ) {
			TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
			transaction = tmp;
			cont.transaction = tmp;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}


@end
