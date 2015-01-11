//
//  TransactionPayment.m
//  myBusiness
//
//  Created by David J. Maier on 1/5/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CreditCardPayment.h"
#import "PSADataManager.h"
#import "TransactionPayment.h"


@implementation TransactionPayment

@synthesize amount, amountOriginal, ccHydrated, creditCardPayment, datePaid, extraInfo, invoiceID, paymentType, transactionPaymentID;

- (id) init {
	amount = nil;
	amountOriginal = nil;
	ccHydrated = NO;
	creditCardPayment = nil;
	datePaid = nil;
	extraInfo = nil;
	invoiceID = -1;
	paymentType = PSATransactionPaymentCash;
	transactionPaymentID = -1;
	return self;
}

- (void) dealloc {
	if( ccHydrated ) {
		[self dehydrateCreditCardPayment];
	}
	[amount release];
	[amountOriginal release];
	[creditCardPayment release];
	[datePaid release];
	[extraInfo release];
	[super dealloc];
}

- (void) dehydrateCreditCardPayment {
	[creditCardPayment release];
	creditCardPayment = nil;
	ccHydrated = NO;
}

- (void) hydrateCreditCardPayment {
	if( !ccHydrated ) {
		[[PSADataManager sharedInstance] getCreditCardPaymentForPayment:self];
		ccHydrated = YES;
	}
}

/*
 *	Do NOT need to release this manually!
 */
- (NSArray*) getPaymentTypes {
//	return [NSArray arrayWithObjects:@"Cash", @"Check", @"Coupon", @"Credit", @"Gift Certificate", @"Credit Card for Processing", nil];
    return [NSArray arrayWithObjects:@"Cash", @"Check", @"Coupon", @"Gift Certificate", @"Credit Card", nil];
}

- (NSString*) stringForType:(PSATransactionPaymentType)type {
	switch (type) {
		case PSATransactionPaymentCash:
			return @"Cash";
		case PSATransactionPaymentCheck:
			return @"Check";
		case PSATransactionPaymentCoupon:
			return @"Coupon";
		case PSATransactionPaymentCredit:
			return @"Credit";
		case PSATransactionPaymentGiftCertificate:
			return @"Gift Certificate";
		case PSATransactionPaymentCreditCardForProcessing:
			return @"Credit Card";
		default:
			return @"None";
	}
	return nil;
}

- (PSATransactionPaymentType) typeForString:(NSString*)str {
	if( [str isEqualToString:@"Cash"] ) {
		return PSATransactionPaymentCash;
	} else if( [str isEqualToString:@"Check"] ) {
		return PSATransactionPaymentCheck;
	} else if( [str isEqualToString:@"Coupon"] ) {
		return PSATransactionPaymentCoupon;
	} else if( [str isEqualToString:@"Credit"] ) {
		return PSATransactionPaymentCredit;
	} else if( [str isEqualToString:@"Gift Certificate"] ) {
		return PSATransactionPaymentGiftCertificate;
	} else if( [str isEqualToString:@"Credit Card"] ) {
		return PSATransactionPaymentCreditCardForProcessing;
	}
	return PSATransactionPaymentCash;
}

@end
