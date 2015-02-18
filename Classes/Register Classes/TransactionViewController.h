//
//  TransactionViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/16/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ClientTableViewController.h"
#import "GiftCertificateViewController.h"
#import "ProductsTableViewController.h"
#import "ServicesTableViewController.h"
#import "TransactionPaymentViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "RegisterViewController.h"
#import "TransactionChargeCell.h"
#import "CreditCardConnectionManager.h"
#import "BaseRegistrationViewController.h"
@class Client, Transaction, TransactionItem;

@interface TransactionViewController : BaseRegistrationViewController 
<CreditCardProcessingViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, PSAClientTableDelegate, PSAGiftCertificateDelegate, PSAProductTableDelegate,
PSATransactionMoneyEntryDelegate, PSATransactionPaymentDelegate, PSAServiceTableDelegate, UIActionSheetDelegate, 
UITableViewDelegate, UITableViewDataSource> 
{
	NSNumberFormatter	*formatter;
	BOOL			isDismissing;
	BOOL			isEditing;
	UITableViewCell	*voidCell;
	UITableView		*tblTransaction;
	Transaction		*transaction;
	// Temp
	Client			*transClient;
	NSMutableArray	*transCertificates;
	NSMutableArray	*transPayments;
	NSMutableArray	*transProducts;
	NSMutableArray	*transServices;
    IBOutlet TransactionChargeCell *chargeCell;
	//
	UITableViewCell	*cellItem;
	UITableViewCell	*cellItemEdit;
	UITableViewCell	*cellPayment;
	UITableViewCell	*cellPaymentEdit;
	//
	NSMutableArray	*ccPaymentsToRemove;
	NSInteger		refundingMethodCall;	// 99 == void, 98 == cancel, 97 == refund w/out void/cancel
    BOOL            isEmailSet;
    NSString        *strEmail;
    bool            isSelectedBoth;
    TransactionPayment *payment;
    IBOutlet UIActivityIndicatorView *activityView;
    MBProgressHUD *progress;
}

@property (nonatomic, assign) BOOL						isEditing;
@property (nonatomic, assign) IBOutlet UITableViewCell	*voidCell;
@property (nonatomic, retain) Transaction				*transaction;
@property (nonatomic, retain) IBOutlet UITableView		*tblTransaction;
//
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellItem;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellItemEdit;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellPayment;
@property (nonatomic, assign) IBOutlet UITableViewCell	*cellPaymentEdit;
@property (nonatomic, assign) BOOL isFirstTime;
@property (nonatomic, assign) RegisterViewController    *parent;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
- (IBAction)			btnVoidPressed:(id)sender;
- (void)				cancelEdit;
- (BOOL)				checkForCreditPayments;
- (BOOL)				checkForNewCreditPayments;
- (TransactionItem*)	createNewTransactionItemWithItem:(NSObject*)theItem;
- (void)				emailReceipt;
- (void)                smsReceipt;
- (void)				refundAllCreditPayments;
- (void)				refundAllNewCreditPayments;
- (void)				refundCreditPayment;
- (void)				removeThisView;
- (void)				save;
- (void)                autoEmailReceipt:(int)nIndex;
@end
