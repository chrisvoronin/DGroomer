//
//  ProjectInvoice.m
//  myBusiness
//
//  Created by David J. Maier on 3/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Company.h"
#import "ProjectInvoiceItem.h"
#import "ProjectProduct.h"
#import "ProjectService.h"
#import "PSADataManager.h"
#import "TransactionPayment.h"
#import "ProjectInvoice.h"


@implementation ProjectInvoice

@synthesize invoiceID, isHydrated, projectID, type;
@synthesize dateDue, dateOpened, datePaid;
@synthesize commissionAmount, name, notes, taxPercent, totalForTable;
@synthesize payments, products, services;


- (id) init {
	invoiceID = -1;
	projectID = -1;
	type = -1;
	dateDue = nil;
	dateOpened = nil;
	datePaid = nil;
	isHydrated = NO;
	name = nil;
	notes = nil;
	payments = [[NSMutableArray alloc] init];
	products = [[NSMutableArray alloc] init];
	services = [[NSMutableArray alloc] init];
	commissionAmount = nil;
	taxPercent = nil;
	totalForTable = nil;
	return self;
}

- (void) dealloc {
	[dateDue release];
	[dateOpened release];
	[datePaid release];
	[name release];
	[notes release];
	[payments release];
	[products release];
	[services release];
	[commissionAmount release];
	[taxPercent release];
	[totalForTable release];
	[super dealloc];
}

#pragma mark -
#pragma mark Data Control
#pragma mark -

- (void) dehydrate {
	isHydrated = NO;
	// Get rid of objects we don't need (stuff in arrays mostly)
	[payments removeAllObjects];
	[products removeAllObjects];
	[services removeAllObjects];
}

- (void) hydrate {
	if( !isHydrated ) {
		// Get all information for this transaction
		//[[PSADataManager sharedInstance] hydrateTransaction:self];
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
	for( ProjectInvoiceItem *tmp in products ) {
		total += [[(ProjectProduct*)tmp.item getDiscountAmount] doubleValue];
	}
	for( ProjectInvoiceItem *tmp in services ) {
		if( type == iBizProjectEstimate ) {
			total += [[(ProjectService*)tmp.item getEstimateDiscountAmount] doubleValue];
		} else {
			total += [[(ProjectService*)tmp.item getDiscountAmount] doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getCertificateSubTotal {
	return [NSNumber numberWithInteger:0];
}

/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getProductSubTotal {
	double total = 0;
	for( ProjectInvoiceItem *tmp in products ) {
		total += ([[(ProjectProduct*)tmp.item getSubTotal] doubleValue]-[[(ProjectProduct*)tmp.item getDiscountAmount] doubleValue]);
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getServiceSubTotal {
	double total = 0;
	for( ProjectInvoiceItem *tmp in services ) {
		if( type == iBizProjectEstimate ) {
			total += ([[(ProjectService*)tmp.item getEstimateSubTotal] doubleValue]-[[(ProjectService*)tmp.item getEstimateDiscountAmount] doubleValue]);
		} else {
			total += ([[(ProjectService*)tmp.item getSubTotal] doubleValue]-[[(ProjectService*)tmp.item getDiscountAmount] doubleValue]);
		}
	}
	return [NSNumber numberWithDouble:total];
}


/*
 *	The total before tax (includes discounts)
 */
- (NSNumber*) getSubTotal {
	double total = 0;
	for( ProjectInvoiceItem *tmp in products ) {
		ProjectProduct *prod = (ProjectProduct*)tmp.item;
		total += ([[prod getSubTotal] doubleValue]-[[prod getDiscountAmount] doubleValue]);
	}
	for( ProjectInvoiceItem *tmp in services ) {
		ProjectService *serv = (ProjectService*)tmp.item;
		if( type == iBizProjectEstimate ) {
			total += ([[serv getEstimateSubTotal] doubleValue]-[[serv getEstimateDiscountAmount] doubleValue]);
		} else {
			total += ([[serv getSubTotal] doubleValue]-[[serv getDiscountAmount] doubleValue]);
		}
	}
	return [NSNumber numberWithDouble:total];
}


/*
 *	The total of taxable item tax amounts.
 *	Certificates are not taxed.
 */
- (NSNumber*) getTax {
	double taxableTotal = 0;
	for( ProjectInvoiceItem *tmp in products ) {
		ProjectProduct *prod = (ProjectProduct*)tmp.item;
		taxableTotal += [[prod getTaxableAmount] doubleValue];
	}
	for( ProjectInvoiceItem *tmp in services ) {
		ProjectService *serv = (ProjectService*)tmp.item;
		if( type == iBizProjectEstimate ) {
			taxableTotal += [[serv getTaxableEstimateAmount] doubleValue];
		} else {
			taxableTotal += [[serv getTaxableAmount] doubleValue];
		}
	}
	// Verify there is tax data
	if( !taxPercent ) {
		// Find out the sales tax
		Company *company = [[PSADataManager sharedInstance] getCompany];
		if( company ) {
			self.taxPercent = company.salesTax;
		}
		[company release];
	}
	// Return
	return [NSNumber numberWithDouble:taxableTotal*([taxPercent doubleValue]/100)];
}


/*
 *	The total due
 */
- (NSNumber*) getTotal {
	double total = [[self getSubTotal] doubleValue];
	total += [[self getTax] doubleValue];
	return [NSNumber numberWithDouble:total];
}

#pragma mark -
#pragma mark Paids
#pragma mark -
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
		if( tmp.amount && tmp.paymentType == PSATransactionPaymentCredit ) {
			total = total + [tmp.amount doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

#pragma mark -
#pragma mark Imports
#pragma mark -

- (void) importProducts:(NSArray*)array {
	[self.products removeAllObjects];
	for( ProjectProduct *prod in array ) {
		ProjectInvoiceItem *tmp = [[ProjectInvoiceItem alloc] init];
		tmp.item = prod;
		[self.products addObject:tmp];
		[tmp release];
	}
}

- (void) importServices:(NSArray*)array {
	[self.services removeAllObjects];
	for( ProjectProduct *prod in array ) {
		ProjectInvoiceItem *tmp = [[ProjectInvoiceItem alloc] init];
		tmp.item = prod;
		[self.services addObject:tmp];
		[tmp release];
	}
}
@end
