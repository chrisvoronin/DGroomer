//
//  Transaction.h
//  myBusiness
//
//  Created by David J. Maier on 12/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "TransactionItem.h"
#import <Foundation/Foundation.h>

@class Client, TransactionItem;

@interface Transaction : NSObject {
	NSInteger		appointmentID;
	Client			*client;
	NSDate			*dateClosed;
	NSDate			*dateOpened;
	NSDate			*dateVoided;
	NSMutableArray	*giftCertificates;
	BOOL			isHydrated;
	NSMutableArray	*payments;
	NSMutableArray	*products;
	NSInteger		projectID;
	NSString		*projectName;
	NSMutableArray	*services;
	NSNumber		*taxAmount;
	NSNumber		*tip;
	NSNumber		*totalForTable;	// For displaying a total without loading transaction items and payments
	NSInteger		transactionID;
}

@property (nonatomic, assign) NSInteger			appointmentID;
@property (nonatomic, retain) Client			*client;
@property (nonatomic, retain) NSDate			*dateClosed;
@property (nonatomic, retain) NSDate			*dateOpened;
@property (nonatomic, retain) NSDate			*dateVoided;
@property (nonatomic, retain) NSMutableArray	*giftCertificates;
@property (nonatomic, assign) BOOL				isHydrated;
@property (nonatomic, retain) NSMutableArray	*payments;
@property (nonatomic, retain) NSMutableArray	*products;
@property (nonatomic, assign) NSInteger			projectID;
@property (nonatomic, retain) NSString			*projectName;
@property (nonatomic, retain) NSMutableArray	*services;
@property (nonatomic, retain) NSNumber			*taxAmount;
@property (nonatomic, retain) NSNumber			*tip;
@property (nonatomic, retain) NSNumber			*totalForTable;
@property (nonatomic, assign) NSInteger			transactionID;

- (id) initWithTransaction:(Transaction*)theTransaction;

- (NSNumber*) getAmountPaid;
- (NSNumber*) getChangeDue;
- (NSNumber*) getDiscounts;
- (NSNumber*) getCertificateSubTotal;
- (NSNumber*) getProductSubTotal;
- (NSNumber*) getServiceSubTotal;
- (NSNumber*) getSubTotal;
- (NSNumber*) getTax;
- (NSNumber*) getTotal;

- (NSNumber*) getCashPaid;
- (NSNumber*) getChecksPaid;
- (NSNumber*) getCouponsPaid;
- (NSNumber*) getCreditPaid;
- (NSNumber*) getGiftCertificatePaid;

- (void) dehydrate;
- (void) hydrate;

@end
