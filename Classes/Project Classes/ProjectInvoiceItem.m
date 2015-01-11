//
//  ProjectInvoiceItem.m
//  myBusiness
//
//  Created by David J. Maier on 3/31/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "ProjectInvoiceItem.h"


@implementation ProjectInvoiceItem

@synthesize invoiceID, item, itemID, invoiceItemID;

- (id) init {
	invoiceItemID = -1;
	invoiceID = -1;
	itemID = -1;
	item = nil;
	return self;
}

- (void) dealloc {
	[item release];
	[super dealloc];
}

@end
