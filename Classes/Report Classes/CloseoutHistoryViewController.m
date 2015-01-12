//
//  CloseoutHistoryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 2/2/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CloseOut.h"
#import "Company.h"
#import "DailyCloseoutViewController.h"
#import "Project.h"
#import "ProjectInvoice.h"
#import "Report.h"
#import "Transaction.h"
#import "TransactionPayment.h"
#import "CloseoutHistoryViewController.h"


@implementation CloseoutHistoryViewController

@synthesize closeoutCell, closeouts, report, tblCloseouts;

- (void) viewDidLoad {
	self.title = @"Daily Closeouts";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Email Button
	UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
	self.navigationItem.rightBarButtonItem = btnEmail;
	[btnEmail release];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	if( !closeouts ) {
		[self.view setUserInteractionEnabled:NO];
		[[PSADataManager sharedInstance] showActivityIndicator];
		[[PSADataManager sharedInstance] setDelegate:self];
		if( report ) {
			if( report.isEntireHistory ) {
				[[PSADataManager sharedInstance] getArrayOfCloseoutsFromDate:nil toDate:nil];
			} else {
				[[PSADataManager sharedInstance] getArrayOfCloseoutsFromDate:report.dateStart toDate:report.dateEnd];
			}
		} else {
			[[PSADataManager sharedInstance] getArrayOfCloseoutsFromDate:nil toDate:nil];
		}
	}
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	[report release];
	self.tblCloseouts = nil;
	[closeouts release];
	//[sortedKeys release];
    [super dealloc];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	closeouts = [theArray retain];
	// Reload and resume normal activity
	[tblCloseouts reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return closeouts.count;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CloseoutHistoryTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"CloseoutHistoryTableCell" owner:self options:nil];
		cell = closeoutCell;
		self.closeoutCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	CloseOut *tmp = [closeouts objectAtIndex:indexPath.row];
	
	UILabel *lbDate = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	lbDate.text = [[PSADataManager sharedInstance] getStringForDate:tmp.date withFormat:NSDateFormatterLongStyle];
	
	NSString *str = [[NSString alloc] initWithFormat:@"%@", [[PSADataManager sharedInstance] getStringForTime:tmp.date withFormat:NSDateFormatterShortStyle]];
	lbStatusTime.text = str;
	[str release];
	
	lbAmount.text = [formatter stringFromNumber:tmp.totalOwed];
	
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
	CloseOut *tmp = [closeouts objectAtIndex:indexPath.row];
	DailyCloseoutViewController *cont = [[DailyCloseoutViewController alloc] initWithNibName:@"DailyCloseoutView" bundle:nil];
	cont.isCloseoutReport = YES;
	cont.closeOut = tmp;
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	UIColor *color = nil;
	if( indexPath.row % 2 == 0 ) {
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
 *
 */
- (void) emailReport {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Date Range
		NSDate *start = report.dateStart;
		if( !start ) {
			if( closeouts.count > 0 ) {
				start = ((CloseOut*)[closeouts objectAtIndex:closeouts.count-1]).date;
			}
		}
		NSDate *end = report.dateEnd;
		if( !end ) {
			if( closeouts.count > 0 ) {
				end = ((CloseOut*)[closeouts objectAtIndex:0]).date;
			}
		}
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		if( company.companyEmail ) {
			NSArray *toRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:toRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Closeout History", (company.companyName) ? company.companyName : @""];
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
									@"Closeout History</b></font> <br/> Start Date: ",
									(start) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:start] : @"None", 
									@"<br/> End Date: ", 
									(end) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:end] : @"None", 
									@"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Closeouts</b></font><br/><br/><table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"><tr align=\"right\"><td width=\"180\" align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"><b>Date Closed</b></td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"><b>Services Performed</b></td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"><b>Retail Sales</b></td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"><b>Certificates Sold</b></td><td width=\"100\" style=\"border-bottom:solid 1px #cccccc;\"><b>Total Owed</b></td><td width=\"100\" style=\"border-bottom:solid 1px #cccccc;\"><b>Total Paid</b></td></tr>"
									];
		
		for( CloseOut *tmp in closeouts ) {
			// TODO: Thread this too?
			NSArray *trannies = [[PSADataManager sharedInstance] getTransactionsUnthreadedForCloseOut:tmp];
			NSArray *payments = [[PSADataManager sharedInstance] getInvoicePaymentsUnthreadedForCloseOut:tmp];
			NSArray *invoices = [[PSADataManager sharedInstance] getInvoiceIDsUnthreadedForCloseOut:tmp];
			NSInteger totalServices = 0;
			NSInteger totalRetail = 0;
			NSInteger totalCerts = 0;
			double totalPaid = 0;
			for( Transaction *trans in trannies ) {
				[trans hydrate];
				totalServices += trans.services.count;
				totalRetail += trans.products.count;
				totalCerts += trans.giftCertificates.count;
				if( [[trans getChangeDue] doubleValue] > 0 ) {
					totalPaid += [[trans getAmountPaid] doubleValue]-[[trans getChangeDue] doubleValue];
				} else {
					totalPaid += [[trans getAmountPaid] doubleValue];
				}
				[trans dehydrate];
			}
			[trannies release];
			for( TransactionPayment *pay in payments ) {
				totalPaid += [pay.amount doubleValue];
			}
			[payments release];
			
			for( NSNumber *invID in invoices ) {
				// This could probably be more efficient, but hydrating a project will get the populated invoice
				Project *project = [[PSADataManager sharedInstance] getProjectWithInvoiceID:[invID integerValue]];
				[project hydrate];
				// Find the invoice...
				for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForInvoices]] ) {
					if( invoice.invoiceID == [invID integerValue] ) {
						// Total up, payments not included
						totalRetail += invoice.products.count;
						totalServices += invoice.services.count;
					}
				}
				[project release];
			}
			[invoices release];
			
			[message appendFormat:@"%@%@%@%d%@%d%@%d%@%@%@%@%@",
			 @"<tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.date],
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 totalServices,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 totalRetail,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 totalCerts,
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [formatter stringFromNumber:tmp.totalOwed],
			 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
			 [formatter stringFromNumber:[NSNumber numberWithFloat:totalPaid]],
			 @"</td></tr>"
			 ];
			
		}
		
		[message appendString:@"</table></td></tr></table></body></html>"];
				
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
