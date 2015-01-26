//
//  CreditCardInformationEntryViewController.h
//  PSA
//
//  Created by David J. Maier on 2/19/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CreditCardConnectionManager.h"
#import "TransactionPaymentViewController.h"
#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"
#import "CardIOPaymentViewControllerDelegate.h"


@class TransactionPayment;

@interface CreditCardPaymentViewController : PSABaseViewController <CreditCardProcessingViewDelegate, UITextFieldDelegate,CardIOPaymentViewControllerDelegate, UITextViewDelegate> {
	NSNumber			*owed;
	TransactionPayment	*payment;
	// Entry
	UIButton	*btnCancelVoidRefund;
	UIButton	*btnCharge;
	UIButton	*btnContacts;
	UIImageView	*ivTip;
	UILabel		*lbOwed;
	UILabel		*lbTotal;
	UITextField *txtAddressStreet;
	UITextField	*txtAddressCity;
	UITextField	*txtAddressState;
	UITextField	*txtAddressZip;
	UITextField	*txtAmount;
	UITextField	*txtCardNumber;
	UITextField	*txtCVV;
	UITextField	*txtEmail;
	UITextField	*txtNameFirst;
	UITextField	*txtNameLast;
	UITextField	*txtPhone;
	UITextField	*txtTip;
    UITextField *txtExpDate;
	// Status Labels
	UILabel		*lbAmount;
	UILabel		*lbDate;
	UITextView	*tvError;
	UILabel		*lbStatus;
	UILabel		*lbTransID;
	UILabel		*lbAmountTitle;
	UILabel		*lbDateTitle;
	UILabel		*lbTransIDTitle;
	//
	UIView			*notesView;
	UIScrollView	*scrollClient;
	//
	UIActivityIndicatorView	*activityView;
	//
	id			delegate;
	BOOL		autoRefunding;
	UIButton	*doneButton;
	BOOL		nonRefundable;
    NSString    *strYear;
    NSString    *strMonth;
    
    IBOutlet UILabel			*placeholderLabel;
    IBOutlet UITextView         *tvNotes;
}

@property (nonatomic, retain) NSNumber				*owed;
@property (nonatomic, retain) TransactionPayment	*payment;

@property (retain, nonatomic) IBOutlet UIScrollView *mainContainer;
@property (nonatomic, retain) IBOutlet UIButton		*btnCancelVoidRefund;
@property (nonatomic, retain) IBOutlet UIButton		*btnCharge;
@property (nonatomic, retain) IBOutlet UIButton		*btnContacts;
@property (nonatomic, retain) IBOutlet UIImageView	*ivTip;
@property (nonatomic, retain) IBOutlet UILabel		*lbOwed;
@property (nonatomic, retain) IBOutlet UILabel		*lbTotal;
@property (nonatomic, retain) IBOutlet UITextField	*txtAddressStreet;
@property (nonatomic, retain) IBOutlet UITextField	*txtAddressCity;
@property (nonatomic, retain) IBOutlet UITextField	*txtAddressState;
@property (nonatomic, retain) IBOutlet UITextField	*txtAddressZip;
@property (nonatomic, retain) IBOutlet UITextField	*txtAmount;
@property (nonatomic, retain) IBOutlet UITextField	*txtCardNumber;
@property (nonatomic, retain) IBOutlet UITextField	*txtCVV;
@property (nonatomic, retain) IBOutlet UITextField	*txtEmail;
@property (nonatomic, retain) IBOutlet UITextField	*txtNameFirst;
@property (nonatomic, retain) IBOutlet UITextField	*txtNameLast;
@property (nonatomic, retain) IBOutlet UITextField	*txtPhone;
@property (nonatomic, retain) IBOutlet UITextField	*txtTip;
@property (retain, nonatomic) IBOutlet UITextView  *tvNotes;
@property (retain, nonatomic) IBOutlet UITextField *txtExpDate;

@property (nonatomic, retain) IBOutlet UIView		*notesView;
@property (nonatomic, retain) IBOutlet UIScrollView	*scrollClient;

@property (nonatomic, retain) IBOutlet UILabel		*lbAmount;
@property (nonatomic, retain) IBOutlet UILabel		*lbDate;
@property (nonatomic, retain) IBOutlet UITextView	*tvError;
@property (nonatomic, retain) IBOutlet UILabel		*lbStatus;
@property (nonatomic, retain) IBOutlet UILabel		*lbTransID;
@property (nonatomic, retain) IBOutlet UILabel		*lbAmountTitle;
@property (nonatomic, retain) IBOutlet UILabel		*lbDateTitle;
@property (nonatomic, retain) IBOutlet UILabel		*lbTransIDTitle;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*activityView;
@property (nonatomic, assign) id <PSATransactionPaymentDelegate> delegate;
@property (nonatomic, assign) BOOL	autoRefunding;
@property (nonatomic, assign) BOOL	nonRefundable;

@property (nonatomic, assign) id currentResponder;

- (IBAction)	cancelVoidRefund:(id)sender;
- (IBAction)	charge:(id)sender;
- (void)		clearFields;
- (void)		close;
- (IBAction)	closeNotes:(id)sender;
- (void)		disableTextFields;
- (void)		dismissKeyboard;
- (void)		done;
- (IBAction)	editNotes:(id)sender;
- (void)		enableTextFields;
- (void)		keyboardWillHide:(NSNotification *)note;
- (void)		keyboardWillShow:(NSNotification *)note;
- (void)		updateTotal;



@end
