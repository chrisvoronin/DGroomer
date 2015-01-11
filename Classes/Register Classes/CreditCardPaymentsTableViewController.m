    //
//  CreditCardPaymentsTableViewController.m
//  PSA
//
//  Created by David J. Maier on 5/26/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "Client.h"
#import "Company.h"
#import "CreditCardPayment.h"
#import "CreditCardPaymentViewController.h"
#import "CreditCardResponse.h"
#import "Report.h"
#import "TransactionPayment.h"
#import "CreditCardPaymentsTableViewController.h"


@implementation CreditCardPaymentsTableViewController

@synthesize report, segViewOptions, tblPayments, ccPaymentsCell;

- (void) viewDidLoad {
	self.title = @"Credit Payments";
	//
	if( report ) {
		// Email Button
		UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
		self.navigationItem.rightBarButtonItem = btnEmail;
		[btnEmail release];
	}
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self getPayments];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[report release];
	self.segViewOptions = nil;
	self.tblPayments = nil;
	[payments release];
	[sortedKeys release];
    [super dealloc];
}

#pragma mark -
#pragma mark Data Loading
#pragma mark -
- (void) getPayments {
	//
	if( payments )	[payments release];
	payments = nil;
	
	[self.segViewOptions setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	
	switch ( segViewOptions.selectedSegmentIndex ) {
		case 0:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getAllCCPaymentsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getAllCCPaymentsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getAllCCPaymentsUnclosed];
			}
			break;
		case 1:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getApprovedCCPaymentsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getApprovedCCPaymentsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getApprovedCCPaymentsUnclosed];
			}
			break;
		case 2:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getRefundedCCPaymentsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getRefundedCCPaymentsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getRefundedCCPaymentsUnclosed];
			}
			break;
		case 3:
			if( report ) {
				if( report.isEntireHistory ) {
					[[PSADataManager sharedInstance] getVoidedCCPaymentsFromDate:nil toDate:nil];
				} else {
					[[PSADataManager sharedInstance] getVoidedCCPaymentsFromDate:report.dateStart toDate:report.dateEnd];
				}
			} else {
				[[PSADataManager sharedInstance] getVoidedCCPaymentsUnclosed];
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
	payments = [[PSADataManager sharedInstance] getDictionaryOfCreditPaymentsFromArray:theArray];
	[self setSortedKeys];
	[tblPayments reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segViewOptions setUserInteractionEnabled:YES];
}

- (void) setSortedKeys {
	// Temporary array of keys sorted by date string ascending
	NSArray	*tmpArray = [[[payments allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
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
	[self getPayments];
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
	return [[payments objectForKey:[sortedKeys objectAtIndex:section]] count];
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
    UITableViewCell *cell = [tblPayments dequeueReusableCellWithIdentifier:@"CreditCardPaymentsTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"CreditCardPaymentsTableCell" owner:self options:nil];
		cell = ccPaymentsCell;
		self.ccPaymentsCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	CreditCardPayment *tmp = [[payments objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	if( tmp ) {
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
		UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
		
		NSString *name = [tmp.client getClientName];
		if( [name isEqualToString:@"No Name"] ) {
			name = [tmp getName];
		}
		lbName.text = name;
		
		NSString *str = nil;
		
		if( tmp.status == CreditCardProcessingVoided ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"VOIDED", [[PSADataManager sharedInstance] getStringForTime:tmp.date withFormat:NSDateFormatterShortStyle]];
		} else if( tmp.status == CreditCardProcessingRefunded ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"REFUNDED", [[PSADataManager sharedInstance] getStringForTime:tmp.date withFormat:NSDateFormatterShortStyle]];
		} else if( tmp.status == CreditCardProcessingApproved ) {
			str = [[NSString alloc] initWithFormat:@"%@ - %@", @"APPROVED", [[PSADataManager sharedInstance] getStringForTime:tmp.date withFormat:NSDateFormatterShortStyle]];
		}
		lbStatusTime.text = str;
		[str release];
		
		NSString *total = [[NSString alloc] initWithFormat:@"$%.2f", [tmp.amount doubleValue]+[tmp.tip doubleValue]];
		lbAmount.text = total;
		[total release];
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
	CreditCardPayment *tmp = [[payments objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	CreditCardPaymentViewController *cont = [[CreditCardPaymentViewController alloc] initWithNibName:@"CreditCardPaymentView" bundle:nil];
	TransactionPayment *tmpPay = [[TransactionPayment alloc] init];
	tmpPay.creditCardPayment = tmp;
	tmpPay.ccHydrated = YES;
	cont.payment = tmpPay;
	[tmpPay release];
	cont.nonRefundable = YES;
	[self.navigationController pushViewController:cont animated:YES];
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGreen.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[cont.view setBackgroundColor:bgColor];
	[bgColor release];
	[cont release];
	 
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	CreditCardPayment *tmp = [[payments objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	UIColor *color = nil;
	if( tmp.status == CreditCardProcessingRefunded || tmp.status == CreditCardProcessingVoided ) {
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
		picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		NSMutableArray *allPayments = [[NSMutableArray alloc] init];
		for( NSString *tmp in sortedKeys ) {
			[allPayments addObjectsFromArray:[payments objectForKey:tmp]];
		}
		
		// Date Range
		NSDate *start = nil;
		if( allPayments.count > 0 ) {
			start = ((CreditCardPayment*)[allPayments objectAtIndex:allPayments.count-1]).date;
		}
		
		NSDate *end = nil;
		if( allPayments.count > 0 ) {
			end = ((CreditCardPayment*)[allPayments objectAtIndex:0]).date;
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
									@"Credit Card Processing History</b></font> <br/>Date: ",
									[[PSADataManager sharedInstance] getStringForAppointmentDate:[NSDate date]],
									@"</td> </tr> </table> </td> </tr>"
									];
		
		[message appendString:@"<tr><td>&nbsp;</td></tr> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"20%\" align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Date</b> </td> <td width=\"12%\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Status</b> </td> <td width=\"12%\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Gateway ID</b> </td> <td width=\"20%\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Client</b> </td> <td width=\"12%\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> <td width=\"12%\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Tip</b> </td> <td width=\"12%\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Total</b> </td> </tr>"];
		double total = 0.0;
		for( CreditCardPayment *payment in allPayments ) {
			
			NSString *status = nil;
			switch (payment.status) {
				case CreditCardProcessingApproved:
					status = @"APPROVED";
					break;
				case CreditCardProcessingRefunded:
					status = @"REFUNDED";
					break;
				case CreditCardProcessingVoided:
					status = @"VOIDED";
					break;
				default:
					status = @"?";
					break;
			}
			
			NSString *name = [payment.client getClientName];
			if( [name isEqualToString:@"No Name"] ) {
				name = [payment getName];
			}
			
			double tmpTotal = [payment.amount doubleValue]+[payment.tip doubleValue];
			total += tmpTotal;
			[message appendFormat:@"%@%@%@%@%@ %@%@%@ %@%@%@ %.2f %@ %.2f %@ %.2f %@",
			 @"<tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [[PSADataManager sharedInstance] getStringForDate:payment.date withFormat:NSDateFormatterMediumStyle],
			 @", ",
			 [[PSADataManager sharedInstance] getStringForTime:payment.date withFormat:NSDateFormatterShortStyle],
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 status,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 payment.response.transID,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 name,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> $ ",
			 [payment.amount doubleValue],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> $ ",
			 [payment.tip doubleValue],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\"> $ ",
			 tmpTotal,
			 @"</td></tr>" ];
		}
		
		[message appendString:@"<tr align=\"right\"> <td colspan=\"6\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"><b>$"];
		
		[message appendFormat:@"%.2f", total ];
		
		[message appendString:@"</b> </td> </tr> </table> </td> </tr></table> </body> </html>"];
		
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
		[allPayments release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil]; 
		[picker release];
		 
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not ready to send email. This is not a %@ setting, you must create an email account on your iPhone, iPad, or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Report!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
		 
}


@end
