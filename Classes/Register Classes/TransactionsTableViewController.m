//
//  TransactionsTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/16/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Company.h"
#import "CreditCardPayment.h"
#import "GiftCertificate.h"
#import "Product.h"
#import "ProductAdjustment.h"
#import "Report.h"
#import "Service.h"
#import "Transaction.h"
#import "TransactionItem.h"
#import	"TransactionPayment.h"
#import "TransactionViewController.h"
#import "TransactionsTableViewController.h"
#import "Settings.h"


@implementation TransactionsTableViewController

@synthesize report, segViewOptions, tblTransactions, transactionsCell;

- (void) viewDidLoad {
	self.title = @"TRANSACTIONS";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
	//
	if( report ) {
		// Email Button
		UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
		self.navigationItem.rightBarButtonItem = btnEmail;
		[btnEmail release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    
    //
    /*Settings *setting = [[PSADataManager sharedInstance] getSettings];
    if(setting.isCloseout){
        NSDate *tDate = [[PSADataManager sharedInstance] todayModifiedWithHours:setting.closeTime];
        if(transactions && [transactions count]>0){
            for( Transaction *tmp in [transactions allValues] ) {
                [[PSADataManager sharedInstance] autoDailyCloseoutForTransactions:tmp theDate:tDate];
            }
        }
    }*/
    Settings *setting = [[PSADataManager sharedInstance] getSettings];
    if(setting.isCloseout){
        NSDate *tDate = [[PSADataManager sharedInstance] todayModifiedWithHours:setting.closeTime];
        [[PSADataManager sharedInstance] autoCloseout:tDate];
    }
    //
    
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [self getTransactions];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	[report release];
	self.segViewOptions = nil;
	self.tblTransactions = nil;
	[transactions release];
	[sortedKeys release];
    [super dealloc];
}

#pragma mark -
#pragma mark Data Loading
#pragma mark -
- (void) getTransactions {
	//
	if( transactions )	[transactions release];
	transactions = nil;

	[self.segViewOptions setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	
	switch ( segViewOptions.selectedSegmentIndex ) {
		case 0:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getAllTransactionsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getAllTransactionsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getAllTransactionsSinceLastCloseout];
			}
			break;
		case 1:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getOpenTransactionsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getOpenTransactionsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getOpenTransactionsSinceLastCloseout];
			}
			break;
		case 2:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getClosedTransactionsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getClosedTransactionsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getClosedTransactionsSinceLastCloseout];
			}
			break;
		case 3:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getVoidedTransactionsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getVoidedTransactionsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getVoidTransactionsSinceLastCloseout];
			}
			break;
		default:
			[[PSADataManager sharedInstance] setDelegate:nil];
			[[PSADataManager sharedInstance] hideActivityIndicator];
			break;
	}
	
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	transactions = [[PSADataManager sharedInstance] getDictionaryOfTransactionsFromArray:theArray];

    [self setSortedKeys];
	[tblTransactions reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segViewOptions setUserInteractionEnabled:YES];
}

- (void) setSortedKeys {
	// Temporary array of keys sorted by date string ascending
	NSArray	*tmpArray = [[[transactions allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
	// Storage for reversal
	NSMutableArray *reverseValues = [[NSMutableArray alloc] init];
	// Go through the tmp and add to the reversed array last->first
	for( int i = tmpArray.count-1; i >= 0; i-- ) {
		[reverseValues addObject:[tmpArray objectAtIndex:i]];
	}
	[tmpArray release];
	// Set the keys
	if( sortedKeys ) [sortedKeys release];
	sortedKeys = reverseValues;
}

#pragma mark -
#pragma mark Action Methods
#pragma mark -
/*
 *
 */
- (IBAction) segViewOptionsChanged:(id)sender {
	// Change the array to view select transactions
	[self getTransactions];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return [sortedKeys count];
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [[transactions objectForKey:[sortedKeys objectAtIndex:section]] count];
}

/*
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDate *tmp = [sortedKeys objectAtIndex:section];
	if( tmp ) {
		return [[PSADataManager sharedInstance] getStringForDate:tmp withFormat:NSDateFormatterLongStyle];
	}
	return @"";
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblTransactions dequeueReusableCellWithIdentifier:@"TransactionsTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"TransactionsTableCell" owner:self options:nil];
		cell = transactionsCell;
		self.transactionsCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

	Transaction *tmp = [[transactions objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	if( tmp ) {
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
		UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
		
		lbName.text = (tmp.client) ? [tmp.client getClientName] : @"No Client";
		
		NSString *str = nil;
		
		if( tmp.dateVoided ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"VOID", [[PSADataManager sharedInstance] getStringForTime:tmp.dateVoided withFormat:NSDateFormatterShortStyle]];
		} else if( tmp.dateClosed ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"CLOSED", [[PSADataManager sharedInstance] getStringForTime:tmp.dateClosed withFormat:NSDateFormatterShortStyle]];
		} else if( tmp.dateOpened ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"OPEN", [[PSADataManager sharedInstance] getStringForTime:tmp.dateOpened withFormat:NSDateFormatterShortStyle]];
		}
		lbStatusTime.text = str;
		[str release];
		
		lbAmount.text = [formatter stringFromNumber:tmp.totalForTable];
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
	Transaction *tmp = [[transactions objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	if( tmp.isHydrated == NO )	[tmp hydrate];
	TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
	cont.transaction = tmp;
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	Transaction *tmp = [[transactions objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	UIColor *color = nil;
	if( tmp.dateVoided ) {
		color = [UIColor colorWithRed:.94 green:.94 blue:.94 alpha:1];
	} else if( tmp.dateClosed ) {
		color = [UIColor colorWithRed:.94 green:.94 blue:.94 alpha:1];
	} else {
		color = [UIColor whiteColor];
	}
	lbName.backgroundColor = color;
	lbStatusTime.backgroundColor = color;
	lbAmount.backgroundColor = color;
	cell.backgroundColor = color;
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
 *	Essentially prints out each receipt for every transaction...
 */
- (void) emailReport {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		NSMutableArray *allTransactions = [[NSMutableArray alloc] init];
		for( NSString *tmp in sortedKeys ) {
			[allTransactions addObjectsFromArray:[transactions objectForKey:tmp]];
		}
		
		// Date Range
		NSDate *start = nil;
		if( allTransactions.count > 0 ) {
			start = ((Transaction*)[allTransactions objectAtIndex:allTransactions.count-1]).dateClosed;
		}
		
		NSDate *end = nil;
		if( allTransactions.count > 0 ) {
			end = ((Transaction*)[allTransactions objectAtIndex:0]).dateClosed;
		}
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Send to self
		if( company.companyEmail ) {
			NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:bccRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Transaction History", (company.companyName) ? company.companyName : @""];
		[picker setSubject:subject];
		[subject release];
		// HTML message
		NSString *companyInfo = [company getMutlilineHTMLString];
		// Static Top
		NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%@%@", 
									@"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size: 12px; } .total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\"><font size=\"5\"><b>",
									(company.companyName) ? company.companyName : @"",
									@"</b></font> <br/>", 
									(companyInfo) ? companyInfo : @"", 
									@"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
									@"Transaction History</b></font> <br/>Date: ",
									[[PSADataManager sharedInstance] getStringForAppointmentDate:[NSDate date]],
									@"</td> </tr> </table> </td> </tr>"
									];
		
		for( Transaction *transaction in allTransactions ) {
			NSString *clientInfo = [transaction.client getMutlilineHTMLStringForReceipt];
			[transaction hydrate];
			[message appendFormat:@"%@%d%@%@%@%@%@",
			 @"<tr><td>&nbsp;</td></tr><tr><td><table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"><tr><td colspan=\"2\"><hr /></td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Transaction:</b></font></td><td valign=\"middle\">",
			 transaction.transactionID,
			 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Date:</b></font></td><td valign=\"middle\">",
			 [[PSADataManager sharedInstance] getStringForAppointmentDate:transaction.dateClosed],
			 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Customer:</b></font></td><td valign=\"middle\">",
			 clientInfo,
			 @"</td></tr></table></td></tr><tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Purchases & Services</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"76\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Item No.</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"30\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Qty.</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"
			 ];
			
			// Add row for each TransactionItem
			for( TransactionItem *item in transaction.services ) {
				NSString *itemID = nil;
				NSString *itemDescription = nil;
				NSInteger quantity = 1;
				
				Service *serv = (Service*)item.item;
				itemID = [[NSString alloc] initWithFormat:@"%d", serv.serviceID];
				itemDescription = [[NSString alloc] initWithString:serv.serviceName];
				
				[message appendFormat:@"%@%@%@%@%@%@%@%@%d%@%@%@%@%@",
				 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemID,
				 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:item.itemPrice],
				 ([item.setupFee doubleValue] > 0.0) ? [NSString stringWithFormat:@"<br/>Setup: %@", [formatter stringFromNumber:item.setupFee]] : @"",
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 quantity,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:[item getDiscountAmount]],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:[item getSubTotal]],
				 @"</td></tr>"
				 ];
				
				[itemID release];
				[itemDescription release];
			}
			
			for( TransactionItem *item in transaction.products ) {
				NSString *itemDescription = nil;
				NSInteger quantity = 1;
				
				Product *prod = (Product*)item.item;
				itemDescription = [[NSString alloc] initWithString:prod.productName];
				if( item.productAdjustment ) {
					quantity = ((ProductAdjustment*)item.productAdjustment).quantity;
				}
				[message appendFormat:@"%@%@%@%@%@%@%@%d%@%@%@%@%@",
				 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 prod.productNumber,
				 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:item.itemPrice],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 quantity,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:[item getDiscountAmount]],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:[item getSubTotal]],
				 @"</td></tr>"
				 ];

				[itemDescription release];
			}
			
			for( TransactionItem *item in transaction.giftCertificates ) {
				NSString *itemID = nil;
				NSString *itemDescription = nil;
				NSInteger quantity = 1;
				
				GiftCertificate *cert = (GiftCertificate*)item.item;
				itemID = [[NSString alloc] initWithFormat:@"%d", cert.certificateID];
				if( cert.recipientLast && cert.recipientFirst ) {
					itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@ %@", cert.recipientFirst, cert.recipientLast];
				} else if( cert.recipientLast ) {
					itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientLast];
				} else if( cert.recipientFirst ) {
					itemDescription = [[NSString alloc] initWithFormat:@"Gift Certificate for %@", cert.recipientFirst];
				} else {
					itemDescription = [[NSString alloc] initWithString:@"Gift Certificate"];
				}
				
				[message appendFormat:@"%@%@%@%@%@%@%@%d%@%@%@%@%@",
				 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemID,
				 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 itemDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:item.itemPrice],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 quantity,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:[item getDiscountAmount]],
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:[item getSubTotal]],
				 @"</td></tr>"
				 ];
				
				[itemID release];
				[itemDescription release];
			}
			
			// Static middle
			[message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@", 
			 @"<tr align=\"right\" class=\"total\"> <td colspan=\"4\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Discount Total</b></font> </td> <td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[transaction getDiscounts]], // Discount Total
			 @"</b> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> &nbsp; </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Tip</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:[transaction tip]], // Tip
			 @"</td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sub-Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[transaction getSubTotal]], // Sub-Total
			 @"</b> </td> </tr> <tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[transaction getTax]], // Tax
			 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Total Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[transaction getTotal]], // Total Balance
			 @"</b> </td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr><tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Payments</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td style=\"border-bottom:solid 1px #cccccc;\"> <b>Payment Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> </tr>"];
			
			// Add row for each TransactionPayment
			for( TransactionPayment *payment in transaction.payments ) {
				NSString *paymentDescription = nil;
				if( payment.paymentType == PSATransactionPaymentCash ) {
					paymentDescription = [[NSString alloc] initWithString:@"Cash"];
				} else if( payment.paymentType == PSATransactionPaymentCheck ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Check No. %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCoupon ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Coupon: %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCredit ) {
					paymentDescription = [[NSString alloc] initWithFormat:@"Credit Card ending in %@", payment.extraInfo];
				} else if( payment.paymentType == PSATransactionPaymentCreditCardForProcessing ) {
					[payment hydrateCreditCardPayment];
					paymentDescription = [[NSString alloc] initWithFormat:@"Credit Card ending in %@", [payment.creditCardPayment.ccNumber substringFromIndex:payment.creditCardPayment.ccNumber.length-4]];
					[payment dehydrateCreditCardPayment];
				} else if( payment.paymentType == PSATransactionPaymentGiftCertificate ) {
					GiftCertificate *cert = [[PSADataManager sharedInstance] getGiftCertificateWithID:[payment.extraInfo integerValue]];
					if( cert ) {
						paymentDescription = [[NSString alloc] initWithFormat:@"Gift Certificate %d", cert.certificateID];
					} else {
						paymentDescription = [[NSString alloc] initWithString:@"Unknown Gift Certificate"];
					}
					[cert release];
				}
				
				[message appendFormat:@"%@%@%@%@%@",
				 @"<tr align=\"right\"><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc; border-left:solid 1px #cccccc;\">",
				 paymentDescription,
				 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
				 [formatter stringFromNumber:payment.amount],
				 @"</td></tr>"
				 ];
				[paymentDescription release];
			}
			
			double change = [[transaction getChangeDue] doubleValue];
			
			// Semi-Static bottom
			[message appendFormat:@"%@%@%@%@%@%@%@",
			 @"<tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Payment Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[transaction getAmountPaid]], // Total Payments
			 @"</b> </td> </tr> <tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>",
			 ( change >= 0 ) ? @"Change" : @"Owed",
			 @"</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
			 [formatter stringFromNumber:[NSNumber numberWithFloat:( change >= 0 ) ? change : change*-1]], // Change
			 @"</b> </td> </tr> </table> </td> </tr>"];
			
			[clientInfo release];
		}
		
		[message appendString:@"</table> </body> </html>"];
		
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
		[allTransactions release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil]; 
		[picker release];
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Report!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}


@end
