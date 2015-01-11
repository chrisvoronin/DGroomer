//
//  ProjectProduct.h
//  myBusiness
//
//  Created by David J. Maier on 3/22/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import <Foundation/Foundation.h>

@class ProductAdjustment;

@interface ProjectProduct : Product {
	NSInteger			projectProductID;
	NSInteger			projectID;
	NSNumber			*cost;
	NSNumber			*price;
	NSNumber			*discountAmount;
	BOOL				isPercentDiscount;
	BOOL				taxed;
	ProductAdjustment	*productAdjustment;
}

@property (nonatomic, retain) NSNumber	*discountAmount;
@property (nonatomic, retain) NSNumber	*cost;
@property (nonatomic, retain) NSNumber	*price;

@property (nonatomic, assign) NSInteger	projectID;
@property (nonatomic, retain) ProductAdjustment	*productAdjustment;
@property (nonatomic, assign) NSInteger	projectProductID;
@property (nonatomic, assign) BOOL		isPercentDiscount;
@property (nonatomic, assign) BOOL		taxed;

- (id) init;
- (id) initWithProduct:(Product *)theProduct;

- (NSNumber*) getDiscountAmount;
- (NSNumber*) getSubTotal;
- (NSNumber*) getTaxableAmount;

@end
