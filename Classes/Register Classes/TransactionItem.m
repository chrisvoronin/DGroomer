//
//  TransactionItem.m
//  myBusiness
//
//  Created by David J. Maier on 12/31/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "Product.h"
#import "ProductAdjustment.h"
#import "Service.h"
#import "TransactionItem.h"


@implementation TransactionItem

@synthesize cost, discountAmount, itemType, isPercentDiscount, item, itemPrice, productAdjustment, setupFee, taxed, transactionItemID;

- (id) init {
	transactionItemID = -1;
	cost = nil;
	discountAmount = [[NSNumber alloc] initWithDouble:0];
	itemType = PSATransactionItemNone;
	isPercentDiscount = YES;
	item = nil;
	itemPrice = nil;
	setupFee = nil;
	// Adjustment for products
	productAdjustment = [[ProductAdjustment alloc] init];
	productAdjustment.type = PSAProductAdjustmentRetail;
	productAdjustment.quantity = 1;
	return self;
}

- (void) dealloc {
	[cost release];
	[item release];
	[itemPrice release];
	[discountAmount release];
	[productAdjustment release];
	[setupFee release];
	[super dealloc];
}

/*
 *	No need to release the returned...
 */
- (NSNumber*) getDiscountAmount {
	if( isPercentDiscount ) {
		double disc = [itemPrice doubleValue]*([discountAmount doubleValue]/100);
		if( productAdjustment && itemType == PSATransactionItemProduct ) {
			return [NSNumber numberWithDouble:disc*productAdjustment.quantity];
		} else {
			double setup = 0;
			if( setupFee ) {
				setup = [setupFee doubleValue]*([discountAmount doubleValue]/100);
			}
			return [NSNumber numberWithDouble:disc+setup];
		}
	} else {
		if( productAdjustment ) {
			return [NSNumber numberWithDouble:[discountAmount doubleValue]*productAdjustment.quantity];
		} else {
			return discountAmount;
		}
	}
	return [NSNumber numberWithInt:0];
}

/*
 *	Total before discounts and tax.
 *	No need to release the returned...
 */
- (NSNumber*) getSubTotal {
	double price = [itemPrice doubleValue];
	double setup = 0;
	if( setupFee ) {
		setup = [setupFee doubleValue];
	}

	if( productAdjustment ) {
		return [NSNumber numberWithDouble:((price*productAdjustment.quantity)+setup)];
	} else {
		return [NSNumber numberWithDouble:price+setup];
	}
}

/*
 *	Certificates are not taxed.
 */
- (NSNumber*) getTaxableAmount {
	double tax = 0;
	if( itemType == PSATransactionItemProduct || itemType == PSATransactionItemService ) {
		if( taxed ) {
			tax += [itemPrice doubleValue];
			if( setupFee ) {
				tax += [setupFee doubleValue];
			}
		}
	}
	if( tax > 0 ) {
		if( productAdjustment ) {
			return [NSNumber numberWithDouble:(tax*productAdjustment.quantity-[[self getDiscountAmount] doubleValue])];
		} else {
			return [NSNumber numberWithDouble:(tax-[[self getDiscountAmount] doubleValue])];
		}
	}
	return [NSNumber numberWithDouble:0];
}

@end
