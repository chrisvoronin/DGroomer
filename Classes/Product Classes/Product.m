//
//  Product.m
//  myBusiness
//
//  Created by David J. Maier on 7/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "Product.h"


@implementation Product

@synthesize productID, productNumber, productName, productCost, productPrice, productMin, isActive, adjustmentsNeedSaving;
@synthesize productMax, productInStock, vendorID, productTypeID, productTaxable, productTypeName, productVendorName;

- (id) init {
	self.productID = -1;
	self.productTypeID = -1;
	self.productNumber = nil;
	self.vendorID = -1;
	self.productCost = 0;
	self.productPrice = 0;
	self.productMin = 0;
	self.productMax = 0;
	self.productInStock = 0;
	self.productTaxable = YES;
	self.isActive = YES;
	self.adjustmentsNeedSaving = nil;
	return self;
}

- (id)initWithProductData:(NSInteger)prodID prodNum:(NSString*)prodNum prodName:(NSString*)prodName prodCost:(NSNumber*)prodCost prodPrice:(NSNumber*)prodPrice prodMin:(NSInteger)prodMin prodMax:(NSInteger)prodMax prodOnHand:(NSInteger)onHand vendor:(NSInteger)vendID prodTyID:(NSInteger)prodTyID tax:(NSInteger)tax {
	self.productID = prodID;
	self.productNumber = prodNum;
	self.productName = prodName;
	self.productCost = prodCost;
	self.productPrice = prodPrice;
	self.productMin = prodMin;
	self.productMax = prodMax;
	self.productInStock = onHand;
	self.vendorID = vendID;
	self.productTypeID = prodTyID;
	self.productTaxable= tax;
	return self;
}

- (void) dealloc {
	[adjustmentsNeedSaving release];
	[productName release];
	[productNumber release];
	[productCost release];
	[productPrice release];
	[productTypeName release];
	[productVendorName release];
	[super dealloc];
}

- (void) addAdjustmentForFuture:(ProductAdjustment*)theAdjustment {
	if( !adjustmentsNeedSaving ) {
		adjustmentsNeedSaving = [[NSMutableArray alloc] init];
	}
	[adjustmentsNeedSaving addObject:theAdjustment];
}

@end
