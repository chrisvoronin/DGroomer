//
//  CurrentInvoicePaymentsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 4/9/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CreditCardPayment.h"
#import "ProjectEstimateInvoiceViewController.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "TransactionPayment.h"
#import "CurrentInvoicePaymentsViewController.h"

@implementation CurrentInvoicePaymentsViewController

@synthesize paymentCell, tblPayments;

- (void) viewDidLoad {
	self.title = @"Cur. Invoice Payments";
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulatePayments];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[formatter release];
	[payments release];
	self.tblPayments = nil;
    [super dealloc];
}

- (void) releaseAndRepopulatePayments {
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	if( payments )	[payments release];	
	[[PSADataManager sharedInstance] getInvoicePaymentsForNextCloseOut];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	payments = [theArray retain];
	// Reload and resume normal activity
	[tblPayments reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( payments )	return payments.count;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CurrentInvoicePaymentsCell"];
	if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"CurrentInvoicePaymentsCell" owner:self options:nil];
		cell = paymentCell;
		self.paymentCell = nil;
	}
	
	TransactionPayment *tmp = [payments objectAtIndex:indexPath.row];
	if( tmp ) {
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
		UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
		
		if( tmp.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
			// These are always in USD for now...
			NSString *amt = [[NSString alloc] initWithFormat:@"$%.2f", [tmp.amount doubleValue]];
			lbAmount.text = amt;
			[amt release];
			
			lbName.text = @"Credit Processed";
			
			if( !tmp.ccHydrated ) {
				[tmp hydrateCreditCardPayment];
			}
			
			NSString *detail = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:tmp.creditCardPayment.date withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:tmp.creditCardPayment.date withFormat:NSDateFormatterShortStyle]];
			lbStatusTime.text = detail;
			[detail release];
			
			if( tmp.ccHydrated ) {
				[tmp dehydrateCreditCardPayment];
			}
			
		} else {
			lbAmount.text = [formatter stringFromNumber:tmp.amount];
			lbName.text = [tmp stringForType:tmp.paymentType];
			
			NSString *detail = [[NSString alloc] initWithFormat:@"%@ %@", [[PSADataManager sharedInstance] getStringForDate:tmp.datePaid withFormat:NSDateFormatterLongStyle], [[PSADataManager sharedInstance] getStringForTime:tmp.datePaid withFormat:NSDateFormatterShortStyle]];
			lbStatusTime.text = detail;
			[detail release];
			
		}
		
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	TransactionPayment *tmp = [payments objectAtIndex:indexPath.row];
	if( tmp ) {
		ProjectInvoice *tmpInvoice = [[PSADataManager sharedInstance] getInvoiceWithPaymentID:tmp.transactionPaymentID];
		if( tmpInvoice ) {
			Project *project = [[PSADataManager sharedInstance] getProjectWithID:tmpInvoice.projectID];
			[project hydrate];
			for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForInvoices]] ) {
				if( invoice.invoiceID == tmpInvoice.invoiceID ) {
					ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
					cont.invoice = invoice;
					cont.project = project;
					cont.isModal = NO;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
				}
			}
			[project release];
		}
		[tmpInvoice release];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

@end
