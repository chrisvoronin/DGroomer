//
//  Project.h
//  myBusiness
//
//  Created by David J. Maier on 3/17/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Client;

typedef enum iBizProjectStatus {
	iBizProjectStatusAll,
	iBizProjectStatusOpen,
	iBizProjectStatusCompleted,
	iBizProjectStatusUnpaid
} iBizProjectStatus;

@interface Project : NSObject {
	// Data
	BOOL		isHydrated;
	Client		*client;
	NSString	*name;
	NSString	*notes;
	NSInteger	projectID;
	NSNumber	*totalForTable;
	// Collections
	NSMutableArray		*appointments;
	NSMutableDictionary	*payments;
	NSMutableArray		*products;
	NSMutableArray		*services;
	// Dates
	NSDate		*dateCompleted;
	NSDate		*dateCreated;
	NSDate		*dateDue;
	NSDate		*dateModified;
}

// Data
@property (nonatomic, retain) Client	*client;
@property (nonatomic, assign) BOOL		isHydrated;
@property (nonatomic, retain) NSString	*name;
@property (nonatomic, retain) NSString	*notes;
@property (nonatomic, assign) NSInteger	projectID;
@property (nonatomic, retain) NSNumber	*totalForTable;
// Collections
@property (nonatomic, retain) NSMutableArray		*appointments;
@property (nonatomic, retain) NSMutableDictionary	*payments;
@property (nonatomic, retain) NSMutableArray		*products;
@property (nonatomic, retain) NSMutableArray		*services;
// Dates
@property (nonatomic, retain) NSDate	*dateCompleted;
@property (nonatomic, retain) NSDate	*dateCreated;
@property (nonatomic, retain) NSDate	*dateDue;
@property (nonatomic, retain) NSDate	*dateModified;

- (void) dehydrate;
- (void) hydrate;

- (NSNumber*)	getAmountOwed;
- (NSNumber*)	getAmountPaid;
- (NSArray*)	getEstimateTotals;
- (NSNumber*)	getInvoiceTotals;
- (NSArray*)	getProductTotals;
- (NSArray*)	getServiceTotals;

- (NSString*) getKeyForEstimates;
- (NSString*) getKeyForInvoices;
- (NSString*) getKeyForTransactions;

@end
