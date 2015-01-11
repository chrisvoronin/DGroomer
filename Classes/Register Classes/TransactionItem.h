//
//  TransactionItem.h
//  myBusiness
//
//  Created by David J. Maier on 12/31/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PSATransactionItemType {
	PSATransactionItemNone,
	PSATransactionItemGiftCertificate,
	PSATransactionItemProduct,
	PSATransactionItemService
} PSATransactionItemType;

@class ProductAdjustment;

@interface TransactionItem : NSObject {
	NSInteger				transactionItemID;
	NSNumber				*discountAmount;
	BOOL					isPercentDiscount;
	NSObject				*item;
	PSATransactionItemType	itemType;
	ProductAdjustment		*productAdjustment;
	NSNumber				*itemPrice;
	NSNumber				*cost;
	BOOL					taxed;
	NSNumber				*setupFee;
}

@property (nonatomic, assign) NSInteger					transactionItemID;
@property (nonatomic, retain) NSNumber					*discountAmount;
@property (nonatomic, assign) BOOL						isPercentDiscount;
@property (nonatomic, retain) NSObject					*item;
@property (nonatomic, assign) PSATransactionItemType	itemType;
@property (nonatomic, retain) ProductAdjustment			*productAdjustment;
@property (nonatomic, retain) NSNumber					*itemPrice;
@property (nonatomic, retain) NSNumber					*cost;
@property (nonatomic, assign) BOOL						taxed;
@property (nonatomic, retain) NSNumber					*setupFee;

- (NSNumber*) getDiscountAmount;
- (NSNumber*) getSubTotal;
- (NSNumber*) getTaxableAmount;


@end
