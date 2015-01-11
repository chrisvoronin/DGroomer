//
//  Product.h
//  myBusiness
//
//  Created by David J. Maier on 7/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductAdjustment;

@interface Product : NSObject {
    // Attributes.
	NSInteger	productID;
	NSString	*productNumber;
	NSString	*productName;
	NSNumber	*productCost;
	NSNumber	*productPrice;
	NSInteger	productMin;
	NSInteger	productMax;
	NSInteger	productInStock;
	NSInteger	vendorID;
	NSInteger	productTypeID;
	NSString	*productTypeName;
	NSString	*productVendorName;
	NSInteger	productTaxable;
	BOOL		isActive;
	// Adjustments that need saving
	NSMutableArray	*adjustmentsNeedSaving;
}


@property (assign, nonatomic) NSInteger	productID;
@property (assign, nonatomic) NSInteger	productMin;
@property (assign, nonatomic) NSInteger	productMax;
@property (assign, nonatomic) NSInteger	productInStock;
@property (assign, nonatomic) NSInteger	vendorID;
@property (assign, nonatomic) NSInteger	productTypeID;
@property (assign, nonatomic) NSInteger productTaxable;
@property (nonatomic, assign) BOOL		isActive;

@property (nonatomic, retain) NSString	*productName;
@property (nonatomic, retain) NSString	*productNumber;
@property (nonatomic, retain) NSNumber	*productCost;
@property (nonatomic, retain) NSNumber	*productPrice;
@property (nonatomic, retain) NSString	*productTypeName;
@property (nonatomic, retain) NSString	*productVendorName;

@property (nonatomic, retain) NSMutableArray	*adjustmentsNeedSaving;

- (id)	init;
- (id)	initWithProductData:(NSInteger)prodID prodNum:(NSString*)prodNum prodName:(NSString*)prodName prodCost:(NSNumber*)prodCost prodPrice:(NSNumber*)prodPrice prodMin:(NSInteger)prodMin prodMax:(NSInteger)prodMax prodOnHand:(NSInteger)onHand vendor:(NSInteger)vendID prodTyID:(NSInteger)prodTyID tax:(NSInteger)tax;

- (void) addAdjustmentForFuture:(ProductAdjustment*)theAdjustment;

@end
