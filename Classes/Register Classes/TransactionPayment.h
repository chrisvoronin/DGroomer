//
//  TransactionPayment.h
//  myBusiness
//
//  Created by David J. Maier on 1/5/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CreditCardPayment;

typedef enum PSATransactionPaymentType {
	PSATransactionPaymentCash,
	PSATransactionPaymentCheck,
	PSATransactionPaymentCoupon,
	PSATransactionPaymentCredit,
	PSATransactionPaymentGiftCertificate,
	PSATransactionPaymentCreditCardForProcessing
} PSATransactionPaymentType;

@interface TransactionPayment : NSObject {
	NSNumber					*amount;
	NSNumber					*amountOriginal;
	NSDate						*datePaid;
	NSString					*extraInfo;
	NSInteger					invoiceID;
	PSATransactionPaymentType	paymentType;
	NSInteger					transactionPaymentID;
	// Credit Card Data
	CreditCardPayment			*creditCardPayment;
	BOOL						ccHydrated;
}

@property (nonatomic, retain) NSNumber					*amount;
@property (nonatomic, retain) NSNumber					*amountOriginal;
@property (nonatomic, assign) BOOL						ccHydrated;
@property (nonatomic, retain) CreditCardPayment			*creditCardPayment;
@property (nonatomic, retain) NSDate					*datePaid;
@property (nonatomic, retain) NSString					*extraInfo;
@property (nonatomic, assign) NSInteger					invoiceID;
@property (nonatomic, assign) PSATransactionPaymentType	paymentType;
@property (nonatomic, assign) NSInteger					transactionPaymentID;

- (void)	dehydrateCreditCardPayment;
- (void)	hydrateCreditCardPayment;

- (NSArray*)					getPaymentTypes;
- (NSString*)					stringForType:(PSATransactionPaymentType)type;
- (PSATransactionPaymentType)	typeForString:(NSString*)str;

@end
