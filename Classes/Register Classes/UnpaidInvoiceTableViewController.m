//
//  UnpaidInvoiceTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 4/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Company.h"
#import "CreditCardPayment.h"
#import "GiftCertificate.h"
#import "ProductAdjustment.h"
#import "Project.h"
#import "ProjectEstimateInvoiceViewController.h"
#import "ProjectInvoice.h"
#import "ProjectInvoiceItem.h"
#import "ProjectProduct.h"
#import "ProjectService.h"
#import "Report.h"
#import "TransactionPayment.h"
#import "UnpaidInvoiceTableViewController.h"


@implementation UnpaidInvoiceTableViewController

@synthesize invoiceCell, report, tblInvoices;

- (void) viewDidLoad {
	if( report ) {
		self.title = @"Invoice History";
		// Email Button
		UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
		self.navigationItem.rightBarButtonItem = btnEmail;
		[btnEmail release];
	} else {
		self.title = @"Unpaid Invoices";
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulateInvoices];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[formatter release];
	[invoices release];
	[report release];
	self.tblInvoices = nil;
    [super dealloc];
}

- (void) releaseAndRepopulateInvoices {
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	if( invoices )	[invoices release];
	if( report ) {
		if( report.isEntireHistory ) {
			[[PSADataManager sharedInstance] getArrayOfInvoicesFromDate:nil toDate:nil];
		} else {
			[[PSADataManager sharedInstance] getArrayOfInvoicesFromDate:report.dateStart toDate:report.dateEnd];
		}
	} else {
		[[PSADataManager sharedInstance] getArrayOfUnpaidInvoicesByType:iBizProjectInvoice];
	}
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	invoices = [theArray retain];
	// Reload and resume normal activity
	[tblInvoices reloadData];
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
	if( invoices )	return invoices.count;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UnpaidInvoiceCell"];
	if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"UnpaidInvoiceCell" owner:self options:nil];
		cell = invoiceCell;
		self.invoiceCell = nil;
	}
	
	ProjectInvoice *tmp = [invoices objectAtIndex:indexPath.row];
	if( tmp ) {
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
		UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
		
		lbName.text = tmp.name;
		
		if( tmp.datePaid ) {
			NSString *detail = [[NSString alloc] initWithFormat:@"Paid: %@", [[PSADataManager sharedInstance] getStringForDate:tmp.datePaid withFormat:NSDateFormatterLongStyle]];
			lbStatusTime.text = detail;
			[detail release];
		} else {
			NSString *detail = [[NSString alloc] initWithFormat:@"Due: %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateDue withFormat:NSDateFormatterLongStyle]];
			lbStatusTime.text = detail;
			[detail release];
			
			if( [[NSDate date] timeIntervalSinceDate:tmp.dateDue] > 0 ) {
				lbAmount.textColor = [UIColor redColor];
			} else {
				lbAmount.textColor = [UIColor blackColor];
			}
		}
		
		lbAmount.text = [formatter stringFromNumber:tmp.totalForTable];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	ProjectInvoice *tmp = [invoices objectAtIndex:indexPath.row];
	if( tmp ) {
		Project *project = [[PSADataManager sharedInstance] getProjectWithID:tmp.projectID];
		[project hydrate];
		for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForInvoices]] ) {
			if( invoice.invoiceID == tmp.invoiceID ) {
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
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark -
#pragma mark Email
#pragma mark -

/*
 *	Essentially prints out each invoice...
 */
- (void) emailReport {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Send to self
		if( company.companyEmail ) {
			NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:bccRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Invoice History", (company.companyName) ? company.companyName : @""];
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
									@"Invoice History</b></font> <br/>Date: ",
									[[PSADataManager sharedInstance] getStringForAppointmentDate:[NSDate date]],
									@"</td> </tr> </table> </td> </tr>"
									];
		
		for( ProjectInvoice *tmp in invoices ) {
			Project *project = [[PSADataManager sharedInstance] getProjectWithID:tmp.projectID];
			[project hydrate];
			for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForInvoices]] ) {
				if( invoice.invoiceID == tmp.invoiceID ) {
					NSString *clientInfo = [project.client getMutlilineHTMLStringForReceipt];

					[message appendFormat:@"%@ %@ %@ %d %@ %@ %@ %@ %@ %@ %@ %@ %@",
					 @"<tr><td>&nbsp;</td></tr><tr><td><table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"><tr><td colspan=\"2\"><hr /></td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Invoice:</b></font></td><td valign=\"middle\">",
					 invoice.name,
					 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>ID:</b></font></td><td valign=\"middle\">",
					 invoice.invoiceID,
					 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Project:</b></font></td><td valign=\"middle\">",
					 project.name,
					 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>",
					 (invoice.datePaid) ? @"Paid:" : @"Due:",
					 @"</b></font></td><td valign=\"middle\">",
					 (invoice.datePaid) ? [[PSADataManager sharedInstance] getStringForDate:invoice.datePaid withFormat:NSDateFormatterLongStyle] : [[PSADataManager sharedInstance] getStringForDate:invoice.dateDue withFormat:NSDateFormatterLongStyle],
					 @"</td></tr><tr><td valign=\"top\" width=\"120\"><font size=\"3\" color=\"#6b6b6b\"><b>Customer:</b></font></td><td valign=\"middle\">",
					 clientInfo,
					 @"</td></tr></table></td></tr>"
					 ];

					
					if( invoice.products.count > 0 ) {
						[message appendString:@"<tr><td>&nbsp;</td></tr> <tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Products</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"76\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Item No.</b> </td> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"30\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Qty.</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"];
						double productTax = 0.0;
						// Add row for each Product
						for( ProjectInvoiceItem *tmp in invoice.products ) {
							ProjectProduct *product = (ProjectProduct*)tmp.item;
							NSString *itemDescription = product.productName;
							// Total up the tax... maybe TODO make this a method of ProjectInvoice?
							productTax += [[product getTaxableAmount] doubleValue]*([company.salesTax doubleValue]/100);
							
							[message appendFormat:@"%@%@ %@%@ %@%@ %@%d %@%@ %@%@ %@",
							 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 (product.productNumber) ? product.productNumber : @"-",
							 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 itemDescription,
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 [formatter stringFromNumber:product.price],
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 product.productAdjustment.quantity,
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 [formatter stringFromNumber:[product getDiscountAmount]],
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
							 [formatter stringFromNumber:[NSNumber numberWithDouble:[[product getSubTotal] doubleValue]-[[product getDiscountAmount] doubleValue]]],
							 @"</td></tr>"
							 ];
						}
						
						[message appendFormat:@"%@ %@ %@ %@ %@",
						 @"<tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
						 [formatter stringFromNumber:[NSNumber numberWithDouble:productTax]],
						 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Product Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
						 [formatter stringFromNumber:[NSNumber numberWithDouble:[[invoice getProductSubTotal] doubleValue]+productTax]],
						 @"</b> </td> </tr> </table> </td> </tr>"
						 ];
					}
					
					if( invoice.services.count > 0 ) {
						[message appendString:@"<tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Services</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Description</b> </td> <td width=\"30\" align=\"center\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Hours</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Rate</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Setup Fee</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Discount</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Line Total</b> </td> </tr>"];
						double serviceTax = 0.0;
						// Add row for each Product
						for( ProjectInvoiceItem *tmp in invoice.services ) {
							ProjectService *service = (ProjectService*)tmp.item;
							// Total up the tax... maybe TODO make this a method of ProjectInvoice?
							if( invoice.type == iBizProjectEstimate ) {
								serviceTax += [[service getTaxableEstimateAmount] doubleValue]*([company.salesTax doubleValue]/100);
							} else {
								serviceTax += [[service getTaxableAmount] doubleValue]*([company.salesTax doubleValue]/100);
							}
							
							NSString *hours = @"";
							if( service.isFlatRate ) {
								hours = @"Flat";
							} else {
								if( invoice.type == iBizProjectInvoice ) {
									hours = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:service.secondsWorked];
								} else {
									hours = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:service.secondsEstimated];
								}
							}
							
							[message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@%@ %@",
							 @"<tr align=\"right\"><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 service.serviceName,
							 @"</td><td align=\"center\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 hours,
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 [formatter stringFromNumber:service.price],
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 [formatter stringFromNumber:service.setupFee],
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
							 (invoice.type == iBizProjectEstimate) ? [formatter stringFromNumber:[service getEstimateDiscountAmount]] : [formatter stringFromNumber:[service getDiscountAmount]],
							 @"</td><td style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\" >",
							 (invoice.type == iBizProjectEstimate) ? [formatter stringFromNumber:[NSNumber numberWithDouble:[[service getEstimateSubTotal] doubleValue]-[[service getEstimateDiscountAmount] doubleValue]]] : [formatter stringFromNumber:[NSNumber numberWithDouble:[[service getSubTotal] doubleValue]-[[service getDiscountAmount] doubleValue]]],
							 @"</td></tr>"
							 ];
						}
						
						[message appendFormat:@"%@%@ %@%@ %@",
						 @"<tr align=\"right\" class=\"total\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Sales Tax</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
						 [formatter stringFromNumber:[NSNumber numberWithDouble:serviceTax]],
						 @"</b> </td> </tr> <tr align=\"right\"> <td colspan=\"5\" style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Service Balance</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
						 [formatter stringFromNumber:[NSNumber numberWithDouble:[[invoice getServiceSubTotal] doubleValue]+serviceTax]],
						 @"</b> </td> </tr> </table> </td> </tr> "
						 ];
					}
					
					
					double paid = [[invoice getAmountPaid] doubleValue];
					double total = [[invoice getTotal] doubleValue];
					
					if( invoice.type == iBizProjectInvoice && invoice.payments.count > 0 ) {
						[message appendString:@"<tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>Payments</b></font> <br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td style=\"border-bottom:solid 1px #cccccc;\"> <b>Payment Description</b> </td> <td width=\"80\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Amount</b> </td> </tr>"];
						// Add row for each TransactionPayment
						for( TransactionPayment *payment in invoice.payments ) {
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
								paymentDescription = [[NSString alloc] initWithFormat:@"Credit Card ending in %@", payment.creditCardPayment.ccNumber];
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
						[message appendFormat:@"%@%@%@",
						 @"<tr align=\"right\" > <td style=\"border-right:solid 1px #cccccc;\"> <font color=\"#666666\"><b>Payment Total</b></font> </td> <td style=\"border-right:solid 1px #cccccc; border-bottom:solid 1px #cccccc;\"> <b>",
						 [formatter stringFromNumber:[NSNumber numberWithDouble:paid]],
						 @"</b> </td> </tr> </table> </td> </tr>"
						 ];
					}
					
					
					[message appendFormat:@"%@%@ %@%@ %@%@",
					 @"</table> <br/><br/><table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr align=\"right\"> <td> <b><font size=\"5\">",
					 (invoice.type == iBizProjectInvoice) ? @"Invoice" : @"Estimate",
					 (paid > 0) ? @" Unpaid" : @"",
					 @" Total:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
					 (paid > total) ? [formatter stringFromNumber:[NSNumber numberWithInt:0]] : [formatter stringFromNumber:[NSNumber numberWithDouble:total-paid]],
					 @"</font></b> </td> </tr> </table> <br/><br/><br/>"
					 ];
					
					if( invoice.notes ) {
						[message appendFormat:@"%@%@%@",
						 @"<table width=\"95%\" height=\"50\" border=\"0\" cellpadding=\"4\" cellspacing=\"0\" align=\"center\"> <tr align=\"left\" valign=\"top\"> <td width=\"50\" style=\"border-top:solid 1px #cccccc;border-bottom:solid 1px #cccccc;border-left:solid 1px #cccccc;\"> Notes: </td> <td style=\"border-top:solid 1px #cccccc;border-bottom:solid 1px #cccccc;border-right:solid 1px #cccccc;\">",
						 invoice.notes,
						 @"</td> </tr> </table>"
						 ];
					}
					
					[clientInfo release];
				}
			}
			[project release];
			
		}
		
		[message appendString:@"</table> </body> </html>"];
		
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
