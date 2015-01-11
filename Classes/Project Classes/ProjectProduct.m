//
//  ProjectProduct.m
//  myBusiness
//
//  Created by David J. Maier on 3/22/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "ProjectProduct.h"


@implementation ProjectProduct

@synthesize cost, discountAmount, price, productAdjustment;
@synthesize isPercentDiscount, projectID, projectProductID, taxed;

- (id) init {
	cost = nil;
	discountAmount = nil;
	price = nil;
	isPercentDiscount = YES;
	projectID = -1;
	projectProductID = -1;
	taxed = YES;
	// Adjustment for products
	productAdjustment = [[ProductAdjustment alloc] init];
	productAdjustment.type = PSAProductAdjustmentRetail;
	productAdjustment.quantity = 1;
	return self;
}

- (id) initWithProduct:(Product*)theProduct {
	self = [self init];
	self.productID				= theProduct.productID;
	self.productNumber			= theProduct.productNumber;
	self.productName			= theProduct.productName;
	self.productCost			= theProduct.productCost;
	self.productPrice			= theProduct.productPrice;
	self.productMin				= theProduct.productMin;
	self.productMax				= theProduct.productMax;
	self.productInStock			= theProduct.productInStock;
	self.vendorID				= theProduct.vendorID;
	self.productTypeID			= theProduct.productTypeID;
	self.productTypeName		= theProduct.productTypeName;
	self.productVendorName		= theProduct.productVendorName;
	self.productTaxable			= theProduct.productTaxable;
	self.isActive				= theProduct.isActive;
	self.adjustmentsNeedSaving	= theProduct.adjustmentsNeedSaving;
	return self;
}

- (void) dealloc {
	[productAdjustment release];
	[cost release];
	[discountAmount release];
	[price release];
	[super dealloc];
}

/*
 *	No need to release the returned...
 */
- (NSNumber*) getDiscountAmount {
	if( isPercentDiscount ) {
		double disc = [price doubleValue]*([discountAmount doubleValue]/100);
		return [NSNumber numberWithDouble:disc*productAdjustment.quantity];
	} else {
		return [NSNumber numberWithDouble:[discountAmount doubleValue]*productAdjustment.quantity];
	}
	return [NSNumber numberWithInt:0];
}

/*
 *	Total before discounts and tax.
 *	No need to release the returned...
 */
- (NSNumber*) getSubTotal {
	return [NSNumber numberWithDouble:[price doubleValue]*productAdjustment.quantity];
}

/*
 *	Certificates are not taxed.
 */
- (NSNumber*) getTaxableAmount {
	double tax = 0;
	if( taxed ) {
		tax += [price doubleValue];
	}	
	if( tax > 0 ) {
		return [NSNumber numberWithDouble:(tax*productAdjustment.quantity-[[self getDiscountAmount] doubleValue])];
	}
	return [NSNumber numberWithDouble:0];
}


@end