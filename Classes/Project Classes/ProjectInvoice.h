//
//  ProjectInvoice.h
//  myBusiness
//
//  Created by David J. Maier on 3/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum iBizInvoiceType {
	iBizProjectEstimate,
	iBizProjectInvoice,
	iBizProjectNonInvoicedPayment
} iBizInvoiceType;

@interface ProjectInvoice : NSObject {
	NSInteger		invoiceID;
	NSInteger		projectID;
	iBizInvoiceType	type;
	
	NSString		*name;
	NSString		*notes;
	
	NSDate			*dateDue;
	NSDate			*dateOpened;
	NSDate			*datePaid;
	
	BOOL			isHydrated;
	
	NSMutableArray	*payments;
	NSMutableArray	*products;
	NSMutableArray	*services;
	
	NSNumber		*commissionAmount;
	NSNumber		*taxPercent;
	NSNumber		*totalForTable;
	
}

@property (nonatomic, assign) NSInteger			invoiceID;
@property (nonatomic, assign) BOOL				isHydrated;
@property (nonatomic, assign) NSInteger			projectID;
@property (nonatomic, assign) iBizInvoiceType	type;

@property (nonatomic, retain) NSString			*name;
@property (nonatomic, retain) NSString			*notes;

@property (nonatomic, retain) NSDate			*dateDue;
@property (nonatomic, retain) NSDate			*dateOpened;
@property (nonatomic, retain) NSDate			*datePaid;

@property (nonatomic, retain) NSNumber			*commissionAmount;
@property (nonatomic, retain) NSNumber			*taxPercent;
@property (nonatomic, retain) NSNumber			*totalForTable;

@property (nonatomic, retain) NSMutableArray	*payments;
@property (nonatomic, retain) NSMutableArray	*products;
@property (nonatomic, retain) NSMutableArray	*services;


- (NSNumber*) getAmountPaid;
- (NSNumber*) getChangeDue;
- (NSNumber*) getDiscounts;
- (NSNumber*) getProductSubTotal;
- (NSNumber*) getServiceSubTotal;
- (NSNumber*) getSubTotal;
- (NSNumber*) getTax;
- (NSNumber*) getTotal;

- (NSNumber*) getCashPaid;
- (NSNumber*) getChecksPaid;
- (NSNumber*) getCouponsPaid;
- (NSNumber*) getCreditPaid;

- (void) dehydrate;
- (void) hydrate;

- (void) importProducts:(NSArray*)array;
- (void) importServices:(NSArray*)array;

@end
