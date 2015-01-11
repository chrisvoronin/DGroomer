//
//  GiftCertificate.m
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "GiftCertificate.h"


@implementation GiftCertificate

@synthesize amountPurchased, amountUsed, certificateID, expiration, message, notes, purchaseDate, purchaser, recipientFirst, recipientLast;

- (id) init {
	self.certificateID = -1;
	self.amountPurchased = nil;
	self.amountUsed = nil;
	self.expiration = nil;
	self.message = nil;
	self.notes = nil;
	self.purchaseDate = nil;
	self.purchaser = nil;
	self.recipientFirst = nil;
	self.recipientLast = nil;
	return self;
}

- (void) dealloc {
	[amountPurchased release];
	[amountUsed release];
	[expiration release];
	[message release];
	[notes release];
	[purchaseDate release];
	[purchaser release];
	[recipientFirst release];
	[recipientLast release];
	[super dealloc];
}


@end
