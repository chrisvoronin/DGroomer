//
//  Project.m
//  myBusiness
//
//  Created by David J. Maier on 3/17/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "ProjectInvoice.h"
#import "ProjectProduct.h"
#import "ProjectService.h"
#import "PSADataManager.h"
#import "Transaction.h"
#import "Project.h"


@implementation Project

@synthesize client, isHydrated, name, notes, projectID, totalForTable;
@synthesize appointments, payments, products, services;
@synthesize dateCreated, dateCompleted, dateDue, dateModified;

- (id) init {
	isHydrated = NO;
	projectID = -1;
	client = nil;
	name = nil;
	notes = nil;
	totalForTable = nil;
	appointments = [[NSMutableArray alloc] init];
	products = [[NSMutableArray alloc] init];
	services = [[NSMutableArray alloc] init];
	
	NSMutableArray *estimates = [[NSMutableArray alloc] init];
	NSMutableArray *invoices = [[NSMutableArray alloc] init];
	NSMutableArray *trannies = [[NSMutableArray alloc] init];
	payments = [[NSMutableDictionary alloc] initWithObjectsAndKeys:estimates, [self getKeyForEstimates], invoices, [self getKeyForInvoices], trannies, [self getKeyForTransactions], nil];
	[estimates release];
	[invoices release];
	[trannies release];
	
	dateCreated = nil;
	dateCompleted = nil;
	dateDue = nil;
	dateModified = nil;
	return self;
}

- (void) dealloc {
	if( isHydrated ) [self dehydrate];
	[appointments release];
	[client release];
	[name release];
	[notes release];
	[totalForTable release];
	[payments release];
	[products release];
	[services release];
	[dateCreated release];
	[dateCompleted release];
	[dateDue release];
	[dateModified release];
	[super dealloc];
}

- (NSString*) getKeyForEstimates {
	return @"Estimates";
}
- (NSString*) getKeyForInvoices {
	return @"Invoices";
}
- (NSString*) getKeyForTransactions {
	return @"Non-Invoiced Transactions";
}

#pragma mark -
#pragma mark Data Control
#pragma mark -

- (void) dehydrate {
	isHydrated = NO;
	// Get rid of objects we don't need (stuff in arrays mostly)
	[appointments removeAllObjects];
	[products removeAllObjects];
	[services removeAllObjects];
	for( NSMutableArray *tmp in [payments allValues] ) {
		[tmp removeAllObjects];
	}
}

- (void) hydrate {
	if( !isHydrated ) {
		// Get all information for this project
		[[PSADataManager sharedInstance] hydrateProject:self];
		//
		isHydrated = YES;
	}
}

#pragma mark -
#pragma mark Other Methods
#pragma mark -
/*
 * No need to release!
 */
- (NSNumber*) getAmountOwed {
	double total = 0;
	for( ProjectInvoice *tmp in [payments objectForKey:[self getKeyForInvoices]] ) {
		double tmpTotal = ([[tmp getTotal] doubleValue]-[[tmp getAmountPaid] doubleValue]);
		if( tmpTotal > 0 ) {
			total += tmpTotal;
		}
	}
	for( Transaction *tmp in [payments objectForKey:[self getKeyForTransactions]] ) {
		if( !tmp.dateVoided ) {
			double tmpTotal = ([[tmp getTotal] doubleValue]-[[tmp getAmountPaid] doubleValue]);
			if( tmpTotal > 0 ) {
				total += tmpTotal;
			}
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 * No need to release!
 */
- (NSNumber*) getAmountPaid {
	double total = 0;
	for( ProjectInvoice *tmp in [payments objectForKey:[self getKeyForInvoices]] ) {
		double tmpChange = [[tmp getChangeDue] doubleValue];
		if( tmpChange > 0 ) {
			total += [[tmp getAmountPaid] doubleValue]-tmpChange;
		} else {
			total += [[tmp getAmountPaid] doubleValue];
		}
	}
	for( Transaction *tmp in [payments objectForKey:[self getKeyForTransactions]] ) {
		double tmpChange = [[tmp getChangeDue] doubleValue];
		if( tmpChange > 0 ) {
			total += [[tmp getAmountPaid] doubleValue]-tmpChange;
		} else {
			total += [[tmp getAmountPaid] doubleValue];
		}
		
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	No need to release!
 */
- (NSArray*) getEstimateTotals {
	double total = 0;
	NSInteger accepted = 0;
	for( ProjectInvoice *tmp in [payments objectForKey:[self getKeyForEstimates]] ) {
		if( tmp.datePaid ) {
			accepted = accepted + 1;
		}
		total += [[tmp getTotal] doubleValue];
	}
	return [NSArray arrayWithObjects:[NSNumber numberWithInteger:accepted], [NSNumber numberWithDouble:total], nil];
}

/*
 *	No need to release!
 */
- (NSNumber*) getInvoiceTotals {
	double total = 0;
	for( ProjectInvoice *tmp in [payments objectForKey:[self getKeyForInvoices]] ) {
		total += [[tmp getTotal] doubleValue];
	}
	for( Transaction *tmp in [payments objectForKey:[self getKeyForTransactions]] ) {
		if( !tmp.dateVoided ) {
			total += [[tmp getTotal] doubleValue];
		}
	}
	return [NSNumber numberWithDouble:total];
}

/*
 *	Returns the quantity at index 0, total at index 1
 *	No need to release the returned object.
 */
- (NSArray*) getProductTotals {
	NSInteger quantity = 0;
	double total = 0;
	for( ProjectProduct *tmp in products ) {
		quantity += tmp.productAdjustment.quantity;
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	return [NSArray arrayWithObjects:[NSNumber numberWithInteger:quantity], [NSNumber numberWithDouble:total], nil];
}

/*
 *	Returns the hours at index 0, total at index 1
 *	No need to release the returned object.
 */
- (NSArray*) getServiceTotals {
	NSInteger secondsWorked = 0;
	double total = 0;
	for( ProjectService *tmp in services ) {
		secondsWorked += tmp.secondsWorked;		
		total += ([[tmp getSubTotal] doubleValue]-[[tmp getDiscountAmount] doubleValue]);
	}
	return [NSArray arrayWithObjects:[NSNumber numberWithInteger:secondsWorked], [NSNumber numberWithDouble:total], nil];
}

@end
