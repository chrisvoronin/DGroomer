//
//  Transaction.m
//  myBusiness
//
//  Created by David J. Maier on 12/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Company.h"
#import "PSADataManager.h"
#import "TransactionItem.h"
#import "TransactionPayment.h"
#import "Transaction.h"


@implementation Transaction

@synthesize appointmentID, client, dateClosed, dateOpened, dateVoided, giftCertificates, isHydrated, payments, products, projectID;
@synthesize projectName, services, taxAmount, tip, totalForTable, transactionID;

- (id) init {
	appointmentID = -1;
	client = nil;
	dateClosed = nil;
	dateOpened = nil;
	dateVoided = nil;
	giftCertificates = [[NSMutableArray alloc] init];
	isHydrated = NO;
	payments = [[NSMutableArray alloc] init];
	products = [[NSMutableArray alloc] init];
	services = [[NSMutableArray alloc] init];
	projectID = -1;
	projectName = nil;
	taxAmount = nil;
	tip = nil;
	totalForTable = nil;
	self.transactionID = -1;
	return self;
}

- (id) initWithTransaction:(Transaction*)theTransaction {
	self.appointmentID = theTransaction.appointmentID;
	self.client = theTransaction.client;
	self.dateClosed = theTransaction.dateClosed;
	self.dateOpened = theTransaction.dateOpened;
	self.dateVoided = theTransaction.dateVoided;
	self.giftCertificates = theTransaction.giftCertificates;
	self.isHydrated = theTransaction.isHydrated;
	self.payments = theTransaction.payments;
	self.products = theTransaction.products;
	self.services = theTransaction.services;
	self.projectID = theTransaction.projectID;
	self.projectName = theTransaction.projectName;
	self.taxAmount = theTransaction.taxAmount;
	self.tip = theTransaction.tip;
	self.totalForTable = theTransaction.totalForTable;
	self.transactionID = theTransaction.transactionID;
	return self;
}

- (void) dealloc {
	[client release];
	[dateClosed release];
	[dateOpened release];
	[dateVoided release];
	[giftCertificates release];
	[payments release];
	[products release];
	[projectName release];
	[services release];
	[taxAmount release];
	[tip release];
	[totalForTable release];
	[super dealloc];
}

#pragma mark -
#pragma mark Data Control
#pragma mark -

- (void) dehydrate {
	isHydrated = NO;
	// Get rid of objects we don't need (stuff in arrays mostly)
	[giftCertificates removeAllObjects];
	[payments removeAllObjects];
	[products removeAllObjects];
	[services removeAllObjects];
}

- (void) hydrate {
	if( !isHydrated ) {
		// Get all information for this transaction
		[[PSADataManager sharedInstance] hydrateTransaction:self];
		//
		isHydrated = YES;
	}
}



#pragma mark -
#pragma mark Mathematical Totals
#pragma mark -
/*
 *	The total of payments
 */
- (NSNumber*) getAmountPaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	Paid - Total Due
 */
- (NSNumber*) getChangeDue {
	double total = [[self getTotal] doubleValue];
	double paid = [[self getAmountPaid] doubleValue];
	return [NSNumber numberWithDouble:(paid-total)];
}

/*
 *	The total of all discounts
 */
- (NSNumber*) getDiscounts {
	double total = 0;
	for( TransactionItem *tmp in giftCertificates ) {
		total += [[tmp getDiscountAmount] doubleValue];
	}
	for( TransactionItem *tmp in products ) {
		total += [[tmp getDiscountAmount] doubleValue];
	}
	for( TransactionItem *tmp in services ) {
		total += [[tmp getDiscountAmount] doubleValue];
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getCertificateSubTotal {
	double total = 0;
	for( TransactionItem *tmp in giftCertificates ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	return [NSNumber numberWithDouble:total];
}
/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getProductSubTotal {
	double total = 0;
	for( TransactionItem *tmp in products ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	return [NSNumber numberWithDouble:total];
}
/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getServiceSubTotal {
	double total = 0;
	for( TransactionItem *tmp in services ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	return [NSNumber numberWithDouble:total];
}


/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getSubTotal {
	double total = 0;
	for( TransactionItem *tmp in giftCertificates ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	for( TransactionItem *tmp in products ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	for( TransactionItem *tmp in services ) {
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	total += [tip doubleValue];
	return [NSNumber numberWithDouble:total];
}


/*
 *	The total of taxable item tax amounts.
 *	Certificates are not taxed.
 */
- (NSNumber*) getTax {
	double taxableTotal = 0;
	for( TransactionItem *tmp in products ) {
		taxableTotal += [[tmp getTaxableAmount] doubleValue];
	}
	for( TransactionItem *tmp in services ) {
		taxableTotal += [[tmp getTaxableAmount] doubleValue];
	}
	// Verify there is tax data
	if( !taxAmount ) {
		// Find out the sales tax
		Company *company = [[PSADataManager sharedInstance] getCompany];
		if( company ) {
			self.taxAmount = company.salesTax;
		}
		[company release];
	}
	
	// Return
	return [NSNumber numberWithDouble:taxableTotal*([taxAmount doubleValue]/100)];
}


/*
 *	The total due
 */
- (NSNumber*) getTotal {
	double total = [[self getSubTotal] doubleValue];
	total += [[self getTax] doubleValue];
	return [NSNumber numberWithDouble:total];
}


/*
 *	The total of cash
 */
- (NSNumber*) getCashPaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount && tmp.paymentType == PSATransactionPaymentCash ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total of checks or cheques
 */
- (NSNumber*) getChecksPaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount && tmp.paymentType == PSATransactionPaymentCheck ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total of coupons
 */
- (NSNumber*) getCouponsPaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount && tmp.paymentType == PSATransactionPaymentCoupon ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total of credit
 */
- (NSNumber*) getCreditPaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount && (tmp.paymentType == PSATransactionPaymentCredit || tmp.paymentType == PSATransactionPaymentCreditCardForProcessing) ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total of credit
 */
- (NSNumber*) getGiftCertificatePaid {
	double total = 0;
	for( TransactionPayment *tmp in payments ) {
		if( tmp.amount && tmp.paymentType == PSATransactionPaymentGiftCertificate ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}
@end
