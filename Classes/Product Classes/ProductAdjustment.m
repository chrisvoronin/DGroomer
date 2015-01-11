//
//  ProductAdjustment.m
//  myBusiness
//
//  Created by David J. Maier on 1/12/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "ProductAdjustment.h"


@implementation ProductAdjustment

@synthesize productAdjustmentID, productID, adjustmentDate, quantity, type;
@synthesize productName;

- (id) init {
	productAdjustmentID = -1;
	productID = -1;
	self.adjustmentDate = [NSDate date];
	quantity = 1;
	productName = nil;
	type = PSAProductAdjustmentRetail;
	return self;
}

- (void) dealloc {
	[adjustmentDate release];
	[productName release];
	[super dealloc];
}

/*
 *	No need to release when finished.
 */
- (NSString*) getStringForType {
	if( type == PSAProductAdjustmentRetail ) {
		return @"Sold As Retail";
	} else if( type == PSAProductAdjustmentProfessional ) {
		return @"Used Professionally";
	} else if( type == PSAProductAdjustmentAdd ) {
		return @"Added To Inventory";
	}
	return nil;
}

@end
