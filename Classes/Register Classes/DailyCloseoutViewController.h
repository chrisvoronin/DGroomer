//
//  DailyCloseoutViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/29/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class CloseOut, Report;

@interface DailyCloseoutViewController : UIViewController <MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	UITableViewCell		*closeoutCell;
	NSNumberFormatter	*formatter;
	NSArray				*paidInvoices;
	NSArray				*invoicePayments;
	BOOL				isCloseoutReport;
	UITableView			*tblCloseout;
	NSArray				*transactions;
	// Totals
	double	certPurchases;
	double	productPurchases;
	double	servicePurchases;
	double	taxPurchases;
	double	tipPurchases;
	double	totalPurchases;
	// Register
	double	cashTotal;
	double	checkTotal;
	double	couponTotal;
	double	creditTotal;
	double	certTotal;
	double	totalMonies;
	// Optional CloseOut and Report
	CloseOut	*closeOut;
	Report		*report;
}

@property (nonatomic, retain) CloseOut					*closeOut;
@property (nonatomic, assign) IBOutlet UITableViewCell	*closeoutCell;
@property (nonatomic, retain) NSArray					*paidInvoices;
@property (nonatomic, retain) NSArray					*invoicePayments;
@property (nonatomic, assign) BOOL						isCloseoutReport;
@property (nonatomic, retain) Report					*report;
@property (nonatomic, retain) IBOutlet UITableView		*tblCloseout;
@property (nonatomic, retain) NSArray					*transactions;

- (void) closeout;
- (void) emailReport;

@end
