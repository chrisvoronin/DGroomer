//
//  ProjectEstimateInvoiceViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "TransactionPaymentViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Project, ProjectInvoice;

@interface ProjectEstimateInvoiceViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSATransactionPaymentDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate> 
{
	NSNumberFormatter	*formatter;
	ProjectInvoice		*invoice;
	Project				*project;
	// Interface
	UITableViewCell	*cellEditButtons;
	UITableViewCell	*cellEstimateButtons;
	UITableViewCell	*cellInvoiceButtons;
	UITableViewCell	*cellInvoiceNotes;
	UITableViewCell	*cellItem;
	UITableViewCell	*cellItemEdit;
	UITableViewCell	*cellPayment;
	UITableViewCell	*cellPaymentEdit;
	BOOL			isModal;
	UITableView		*tblInvoice;
	// Temporary Invoice Datas (Editing)
	NSDate			*invoiceDateDue;
	NSMutableArray	*invoicePayments;
	NSMutableArray	*invoiceProducts;
	NSMutableArray	*invoiceServices;
	NSString		*invoiceName;
	NSString		*invoiceNotes;
	//
	NSMutableArray	*ccPaymentsToRemove;
	NSInteger		refundingMethodCall;	// 99 == void, 98 == cancel, 97 == refund w/out void/cancel
}

@property (nonatomic, retain) ProjectInvoice	*invoice;
@property (nonatomic, retain) Project			*project;
//
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellEditButtons;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellEstimateButtons;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellInvoiceButtons;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellInvoiceNotes;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellItem;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellItemEdit;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellPayment;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellPaymentEdit;
@property (nonatomic, assign) BOOL						isModal;
@property (nonatomic, retain) IBOutlet UITableView		*tblInvoice;

- (IBAction)	acceptEstimate;
- (void)		addInvoicePayment;
- (void)		cancelEdit;
- (IBAction)	copyToInvoice:(id)sender;
- (void)		deleteCurrentInvoice;
- (IBAction)	deleteInvoice:(id)sender;
- (void)		edit;
- (IBAction)	email:(id)sender;
- (IBAction)	importProjectItems:(id)sender;
- (void)		save;

- (BOOL)		checkForCreditPayments;
- (BOOL)		checkForNewCreditPayments;
- (void)		refundAllCreditPayments;
- (void)		refundAllNewCreditPayments;
- (void)		refundCreditPayment;

@end
