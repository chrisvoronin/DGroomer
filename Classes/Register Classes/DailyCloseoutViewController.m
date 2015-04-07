//
//  DailyCloseoutViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/29/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Company.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "Report.h"
#import	"Transaction.h"
#import "TransactionItem.h"
#import "TransactionPayment.h"
#import "DailyCloseoutViewController.h"
#import "Settings.h"

@implementation DailyCloseoutViewController

@synthesize closeOut, closeoutCell, invoicePayments, isCloseoutReport, report, paidInvoices, tblCloseout, transactions;

- (void)viewDidLoad {
	self.title = @"Daily Closeout";
	//
	/*UIImage *bg = nil;
	if( isCloseoutReport ) {
		bg = [UIImage imageNamed:@"pinstripeBackgroundAquamarine.png"];
	} else {
		bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	}
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblCloseout setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	//
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	if( isCloseoutReport ) {
		// Email Button
		UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
		self.navigationItem.rightBarButtonItem = btnEmail;
		[btnEmail release];
	} else {
		UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Closeout" style:UIBarButtonItemStyleDone target:self action:@selector(closeout)];
		self.navigationItem.rightBarButtonItem = btnSave;
		[btnSave release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    
    Settings *setting = [[PSADataManager sharedInstance] getSettings];
    if(setting.isCloseout){
        NSDate *tDate = [[PSADataManager sharedInstance] todayModifiedWithHours:setting.closeTime];
        [[PSADataManager sharedInstance] autoCloseout:tDate];
    }
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	// Get the transactions first, invoice payments will follow
	if( !transactions ) {
		[self.view setUserInteractionEnabled:NO];
		[[PSADataManager sharedInstance] showActivityIndicator];
		[[PSADataManager sharedInstance] setDelegate:self];
		if( isCloseoutReport ) {
			if( closeOut ) {
				[[PSADataManager sharedInstance] getTransactionsForCloseOut:closeOut];
			} else if( report ) {
				[[PSADataManager sharedInstance] getTransactionsForCloseOutsFromDate:report.dateStart toDate:report.dateEnd];
			}
		} else {
			[[PSADataManager sharedInstance] getAllTransactionsSinceLastCloseout];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.tblCloseout = nil;
	[closeOut release];
	[formatter release];
	[invoicePayments release];
	[report release];
	[paidInvoices release];
	[transactions release];
    [super dealloc];
}

- (void) closeout {
	// Do the closeout
	if( totalMonies > 0 ) {
		// Only if there is some money in the register!
		[[PSADataManager sharedInstance] insertDailyCloseoutForTransactions:transactions andInvoicePayments:invoicePayments andInvoices:paidInvoices];
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Closeout Failed!" message:@"There are no payments to closeout!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	if( !transactions ) {
		// Set the returned array
		transactions = [theArray retain];
		// Get the invoice payments

		if( isCloseoutReport ) {
			if( closeOut ) {
				[[PSADataManager sharedInstance] getInvoicePaymentsForCloseOut:closeOut];
			} else if( report ) {
				[[PSADataManager sharedInstance] getInvoicePaymentsForCloseOutsFromDate:report.dateStart toDate:report.dateEnd];
			}
		} else {
			[[PSADataManager sharedInstance] getInvoicePaymentsForNextCloseOut];
		}

	} else if( !invoicePayments ) {
		// Set the returned array
		invoicePayments = [theArray retain];
		
		if( isCloseoutReport ) {
			if( closeOut ) {
				[[PSADataManager sharedInstance] getInvoiceIDsForCloseOut:closeOut];
			} else if( report ) {
				[[PSADataManager sharedInstance] getInvoiceIDsForCloseOutsFromDate:report.dateStart toDate:report.dateEnd];
			}
		} else {
			[[PSADataManager sharedInstance] getInvoiceIDsForNextCloseOut];
		}
		
	} else if( !paidInvoices ) {
		
		// Set the returned array
		paidInvoices = [theArray retain];

		// Calculations
		certPurchases = 0;
		productPurchases = 0;
		servicePurchases = 0;
		taxPurchases = 0;
		tipPurchases = 0;
		totalPurchases = 0;
		// Register
		cashTotal = 0;
		checkTotal = 0;
		couponTotal = 0;
		creditTotal = 0;
		certTotal = 0;
		totalMonies = 0;
		
		for( Transaction *transaction in transactions ) {
			// If it's closed and not void
			if( transaction.dateClosed > 0 && !transaction.dateVoided ) {
				// Hydrate
				[transaction hydrate];
				// Get totals
				certPurchases += [[transaction getCertificateSubTotal] doubleValue];
				productPurchases += [[transaction getProductSubTotal] doubleValue];
				servicePurchases += [[transaction getServiceSubTotal] doubleValue];
				taxPurchases += [[transaction getTax] doubleValue];
				tipPurchases += [transaction.tip doubleValue];
				totalPurchases += [[transaction getTotal] doubleValue];
				// Payments
				double change = [[transaction getChangeDue] doubleValue];
				if( change > 0 ) {
					cashTotal += ([[transaction getCashPaid] doubleValue]-change);
				} else {
					cashTotal += [[transaction getCashPaid] doubleValue];
				}
				certTotal += [[transaction getGiftCertificatePaid] doubleValue];
				checkTotal += [[transaction getChecksPaid] doubleValue];
				couponTotal += [[transaction getCouponsPaid] doubleValue];
				creditTotal += [[transaction getCreditPaid] doubleValue];
			}
		}
		
		for( TransactionPayment *payment in invoicePayments ) {
			switch (payment.paymentType) {
				case PSATransactionPaymentCash:
					cashTotal += [payment.amount doubleValue];
					break;
				case PSATransactionPaymentCheck:
					checkTotal += [payment.amount doubleValue];
					break;
				case PSATransactionPaymentCoupon:
					couponTotal += [payment.amount doubleValue];
					break;
				case PSATransactionPaymentCreditCardForProcessing:
				case PSATransactionPaymentCredit:
					creditTotal += [payment.amount doubleValue];
					break;
				case PSATransactionPaymentGiftCertificate:
					certTotal += [payment.amount doubleValue];
					break;
			}
		}
		
		for( NSNumber *invID in paidInvoices ) {
			// This could probably be more efficient, but hydrating a project will get the populated invoice
			Project *project = [[PSADataManager sharedInstance] getProjectWithInvoiceID:[invID integerValue]];
			[project hydrate];
			// Find the invoice...
			for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForInvoices]] ) {
				if( invoice.invoiceID == [invID integerValue] ) {
					// Total up
					productPurchases += [[invoice getProductSubTotal] doubleValue];
					servicePurchases += [[invoice getServiceSubTotal] doubleValue];
					taxPurchases += [[invoice getTax] doubleValue];
					totalPurchases += [[invoice getTotal] doubleValue];
				}
			}
			[project release];
		}
		
		totalMonies = cashTotal+certTotal+checkTotal+couponTotal+creditTotal;
		[tblCloseout reloadData];
		
		[[PSADataManager sharedInstance] setDelegate:nil];
		[[PSADataManager sharedInstance] hideActivityIndicator];
		[self.view setUserInteractionEnabled:YES];
	}
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 6;
}

/*
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( section == 0 ) {
#ifdef PROJECT_NOT_INCLUDED
		return @"Sales & Services";
#else
		return @"Transaction Sales & Services";
#endif
	}
	if( section == 1 ) {
#ifdef PROJECT_NOT_INCLUDED
		return @"Payments";
#else
		return @"Transaction & Invoice Payments";
#endif
	}
	return nil;
}


/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Commented out stuff is for a custom cell where the user could enter their amounts
	/*NSString *identifier = @"DailyCloseoutCell";
	if( indexPath.section == 0 ) {
		identifier = @"DailyCloseoutCellTotals";
	}*/
	NSString *identifier = @"DailyCloseoutCellTotals";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		/*
		if( indexPath.section == 1 ) {
			// Load the NIB
			[[NSBundle mainBundle] loadNibNamed:@"DailyCloseoutCell" owner:self options:nil];
			cell = closeoutCell;
			self.closeoutCell = nil;
		} else {*/
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DailyCloseoutCellTotals"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UIColor *tmp = cell.textLabel.textColor;
		cell.textLabel.textColor = cell.detailTextLabel.textColor;
		cell.detailTextLabel.textColor = tmp;
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
		//}
    }
	
	NSString *total = nil;
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Services";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:servicePurchases]];
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Tips";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:tipPurchases]];
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Products";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:productPurchases]];
			} else if( indexPath.row == 3 ) {
				cell.textLabel.text = @"Gift Certs.";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:certPurchases]];
			} else if( indexPath.row == 4 ) {
				cell.textLabel.text = @"Tax";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:taxPurchases]];
			} else if( indexPath.row == 5 ) {
				cell.textLabel.text = @"Total";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:totalPurchases]];
			}
			break;
		case 1: {
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Cash";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:cashTotal]];
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Checks";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:checkTotal]];
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Coupons";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:couponTotal]];
			} else if( indexPath.row == 3 ) {
				cell.textLabel.text = @"Credit";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:creditTotal]];
			} else if( indexPath.row == 4 ) {
				cell.textLabel.text = @"Gift Certs.";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:certTotal]];
			} else if( indexPath.row == 5 ) {
				cell.textLabel.text = @"Total";
				total = [formatter stringFromNumber:[NSNumber numberWithFloat:totalMonies]];
			}
			break;
		}
	}
	cell.detailTextLabel.text = total;
	total = nil;
	
	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark Email Report
#pragma mark -
/*
 *
 */
- (void) emailReport {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Date Range
		NSDate *end = nil;
		if( transactions.count > 0 ) {
			end = ((Transaction*)[transactions objectAtIndex:transactions.count-1]).dateClosed;
		}

		NSDate *start = nil;
		if( transactions.count > 0 ) {
			start = ((Transaction*)[transactions objectAtIndex:0]).dateClosed;
		}
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		if( company.companyEmail ) {
			NSArray *toRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:toRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Closeout Totals", (company.companyName) ? company.companyName : @""];
		[picker setSubject:subject];
		[subject release];
		// HTML message
		NSString *companyInfo = [company getMutlilineHTMLString];
		// Static Top
		NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%@%@%@%@", 
									@"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size: 12px; } .total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\"><font size=\"5\"><b>",
									(company.companyName) ? company.companyName : @"",
									@"</b></font> <br/>", 
									(companyInfo) ? companyInfo : @"", 
									@"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
									@"Closeout Totals</b></font> <br/> Start Date: ",
									(start) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:start] : @"None", 
									@"<br/> End Date: ", 
									(end) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:end] : @"None", 
									@"</td> </tr> </table> </td> </tr>"
									];
		
		[message appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
		 @"<tr><td>&nbsp;</td></tr><tr><td><table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"><tr align=\"right\"><td width=\"150\" align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"><b>Sales</b></td><td style=\"border-bottom:solid 1px #cccccc;\">&nbsp;</td><td width=\"25\" align=\"center\">&nbsp;</td><td width=\"150\" align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"><b>Payments</b></td><td style=\"border-bottom:solid 1px #cccccc;\">&nbsp;</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Services</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:servicePurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Cash</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:cashTotal]],
		 @"</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Tips</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:tipPurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Checks</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:checkTotal]],
		 @"</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Products</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:productPurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Coupons</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:couponTotal]],
		 @"</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Gift Certificates</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:certPurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Credit</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:creditTotal]],
		 @"</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Tax</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:taxPurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Gift Certificates</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:certTotal]],
		 @"</td></tr><tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">Total</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:totalPurchases]],
		 @"</td><td>&nbsp;</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">Total</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
		 [formatter stringFromNumber:[NSNumber numberWithFloat:totalMonies]],
		 @"</td></tr></table></td></tr></table></body></html>"
		 ];

		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil]; 
		//[picker release];
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Report!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}


@end
