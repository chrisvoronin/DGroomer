//
//  TransactionPaymentViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/5/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificateTableViewController.h"
#import "TablePickerViewController.h"
#import "TransactionMoneyEntryViewController.h"
#import <UIKit/UIKit.h>

@class TransactionPayment;

// Protocol Definition
@protocol PSATransactionPaymentDelegate <NSObject>
@required
- (void) completedNewPayment:(TransactionPayment*)thePayment;
@optional
- (void) autoRefundedCreditPayment:(TransactionPayment*)thePayment;
- (void) refundedCreditPayment:(TransactionPayment*)thePayment;
@end

@interface TransactionPaymentViewController : UIViewController 
<PSAGiftCertificateTableDelegate, PSATransactionMoneyEntryDelegate, PSATablePickerDelegate, UITableViewDataSource, UITableViewDelegate> 
{
	NSNumber			*amountOwed;
	id					delegate;
	BOOL				editing;
	NSNumberFormatter	*formatter;
	BOOL				isInvoicePayment;
	TransactionPayment	*payment;
	UITableView			*tblPayment;
}

@property (nonatomic, retain) NSNumber				*amountOwed;
@property (nonatomic, assign) id <PSATransactionPaymentDelegate> delegate;
@property (nonatomic, assign) BOOL					editing;
@property (nonatomic, assign) BOOL					isInvoicePayment;
@property (nonatomic, retain) TransactionPayment	*payment;
@property (nonatomic, retain) IBOutlet UITableView	*tblPayment;

- (void) done;
- (void) cancelEdit;
@end
