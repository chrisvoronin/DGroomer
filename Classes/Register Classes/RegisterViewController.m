//
//  RegisterViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "CreditCardPaymentsTableViewController.h"
#import "CurrentInvoicePaymentsViewController.h"
#import "DailyCloseoutViewController.h"
#import "GiftCertificateTableViewController.h"
#import "GiftCertificateViewController.h"
#import "TransactionsTableViewController.h"
#import "TransactionViewController.h"
#import "UnapprovedEstimatesTableViewController.h"
#import "UnpaidInvoiceTableViewController.h"
#import "RegisterViewController.h"


@implementation RegisterViewController

@synthesize tblRegister;

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
	self.title = @"Get Paid";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblRegister setBackgroundColor:bgColor];
	[bgColor release];*/
	//
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblRegister = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return 2;
	else if( section == 2 ) {
#ifdef PROJECT_NOT_INCLUDED
		return 1;
#else
		return 4;
#endif
	}
	return 1;
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
				cell.textLabel.text = @"New Transaction";
			} else {
				cell.textLabel.text = @"Current Transactions";
			}
			break;
		case 1:
			cell.textLabel.text = @"Gift Certificates";
			break;
		case 2:
			if( indexPath.row == 0 ) {
#ifdef PROJECT_NOT_INCLUDED
				cell.textLabel.text = @"Recent Credit Payments";
#else
				cell.textLabel.text = @"Current Invoice Payments";
#endif
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Recent Credit Payments";
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Unapproved Estimates";
			} else {
				cell.textLabel.text = @"Unpaid Invoices";
			}
			break;
		case 3:
			cell.textLabel.text = @"Daily Closeout";
			break;
	}
	
	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// GoTo
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				// Single (new) transaction
				TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
				cont.isEditing = YES;
				UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
				cont.navigationItem.leftBarButtonItem = cancel;
				[cancel release];
				UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
				[cont release];
				//nav.navigationBar.tintColor = [UIColor blackColor];
				[self presentViewController:nav animated:YES completion:nil];
				[nav release];
			} else {
				// Transactions Table
				TransactionsTableViewController *cont = [[TransactionsTableViewController alloc] initWithNibName:@"TransactionsTableView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			}
			break;
		case 1: {
			// Gift Certificates Table
			GiftCertificateTableViewController *cont = [[GiftCertificateTableViewController alloc] initWithNibName:@"GiftCertificateTableView" bundle:nil];
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
		case 2: {
			if( indexPath.row == 0 ) {
#ifdef PROJECT_NOT_INCLUDED
				CreditCardPaymentsTableViewController *cont = [[CreditCardPaymentsTableViewController alloc] initWithNibName:@"CreditCardPaymentsTableView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
#else
				CurrentInvoicePaymentsViewController *cont = [[CurrentInvoicePaymentsViewController alloc] initWithNibName:@"CurrentInvoicePaymentsView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
#endif
				break;
			} else if( indexPath.row == 1 ) {
				CreditCardPaymentsTableViewController *cont = [[CreditCardPaymentsTableViewController alloc] initWithNibName:@"CreditCardPaymentsTableView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
				break;
			} else if( indexPath.row == 2 ) {
				UnapprovedEstimatesTableViewController *cont = [[UnapprovedEstimatesTableViewController alloc] initWithNibName:@"UnapprovedEstimatesTableView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			} else {
				UnpaidInvoiceTableViewController *cont = [[UnpaidInvoiceTableViewController alloc] initWithNibName:@"UnpaidInvoiceTableView" bundle:nil];
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			}
			break;
		}
		case 3: {
			DailyCloseoutViewController *cont = [[DailyCloseoutViewController alloc] initWithNibName:@"DailyCloseoutView" bundle:nil];
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
	}
}

@end
