//
//  ProductHistoryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 2/3/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Company.h"
#import "ProductAdjustment.h"
#import "ProductInformationViewController.h"
#import "Report.h"
#import "ProductHistoryViewController.h"


@implementation ProductHistoryViewController

@synthesize productHistoryCell, products, report, tblProducts;

- (void) viewDidLoad {
	self.title = @"Product History";
	// Email Button
	UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
	self.navigationItem.rightBarButtonItem = btnEmail;
	[btnEmail release];
	//
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	if( products )	[products release];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getProductAdjustmentsForReport:report];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[report release];
	self.tblProducts = nil;
	[products release];
	//[sortedKeys release];
    [super dealloc];
}


- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	products = [theArray retain];
	[tblProducts reloadData];
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
	return products.count;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ProductHistoryTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"ProductHistoryTableCell" owner:self options:nil];
		cell = productHistoryCell;
		self.productHistoryCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	ProductAdjustment *tmp = [products objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	lbName.text = tmp.productName;
	
	NSString *info = nil;
	if( tmp.type == PSAProductAdjustmentAdd ) {
		info = [[NSString alloc] initWithFormat:@"%@ - %@", [[PSADataManager sharedInstance] getStringForDate:tmp.adjustmentDate withFormat:NSDateFormatterShortStyle], @"Added To Inventory"];
		lbAmount.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	} else if( tmp.type == PSAProductAdjustmentProfessional ) {
		info = [[NSString alloc] initWithFormat:@"%@ - %@", [[PSADataManager sharedInstance] getStringForDate:tmp.adjustmentDate withFormat:NSDateFormatterShortStyle], @"Used Professionally"];
		lbAmount.textColor = [UIColor redColor];
	} else if( tmp.type == PSAProductAdjustmentRetail ) {
		info = [[NSString alloc] initWithFormat:@"%@ - %@", [[PSADataManager sharedInstance] getStringForDate:tmp.adjustmentDate withFormat:NSDateFormatterShortStyle], @"Sold As Retail"];
		lbAmount.textColor = [UIColor redColor];
	}
	lbStatusTime.text = info;
	[info release];
	
	NSString *total = [[NSString alloc] initWithFormat:@"%@ %d", (tmp.type != PSAProductAdjustmentAdd) ? @"-" : @"+", tmp.quantity];
	lbAmount.text = total;
	[total release];
	
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
	ProductAdjustment *tmp = [products objectAtIndex:indexPath.row];
	Product *product = [[PSADataManager sharedInstance] getProductWithID:tmp.productID];
	ProductInformationViewController *cont = [[ProductInformationViewController alloc] initWithNibName:@"ProductInformation" bundle:nil];
	cont.product = product;
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
	[product release];
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
		picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Date Range
		NSDate *start = nil;
		if( products.count > 0 ) {
			start = ((ProductAdjustment*)[products objectAtIndex:products.count-1]).adjustmentDate;
		}
		
		NSDate *end = nil;
		if( products.count > 0 ) {
			end = ((ProductAdjustment*)[products objectAtIndex:0]).adjustmentDate;
		}
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		if( company.companyEmail ) {
			NSArray *toRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:toRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Inventory History", (company.companyName) ? company.companyName : @""];
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
									@"Inventory History</b></font> <br/> Start Date: ",
									(start) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:start] : @"None", 
									@"<br/> End Date: ", 
									(end) ? [[PSADataManager sharedInstance] getStringForAppointmentDate:end] : @"None", 
									@"</td> </tr> </table> </td> </tr><tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Product Sales, Usage, and Restocking</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"180\" align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Date</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Product Name</b> </td> <td width=\"150\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Type</b> </td> <td width=\"80\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Quantity</b> </td> </tr>"
									];
		
		for( ProductAdjustment *tmp in products ) {
			[message appendFormat:@"%@%@%@%@%@%@%@%d%@",
			 @"<tr align=\"right\"><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.adjustmentDate],
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 tmp.productName,
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 [tmp getStringForType],
			 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
			 tmp.quantity,
			 @"</td></tr>"
			 ];
		}
		
		[message appendString:@"</table></td></tr></table></body></html>"];
		 
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
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
