//
//  UnpaidInvoiceTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 4/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class Report;

@interface UnpaidInvoiceTableViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> 
{
	NSNumberFormatter	*formatter;
	NSArray			*invoices;
	UITableViewCell	*invoiceCell;
	UITableView		*tblInvoices;
	// Leave nil if not generating a Transaction report
	Report				*report;
}

@property (nonatomic, retain) IBOutlet UITableViewCell	*invoiceCell;
@property (nonatomic, retain) IBOutlet UITableView		*tblInvoices;
@property (nonatomic, retain) Report					*report;

- (void) emailReport;
- (void) releaseAndRepopulateInvoices;

@end
