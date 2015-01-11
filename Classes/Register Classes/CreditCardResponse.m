//
//  CreditCardResponse.m
//  PSA
//
//  Created by David J. Maier on 5/11/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import "CreditCardResponse.h"


@implementation CreditCardResponse

@synthesize errors, messages;
@synthesize responseCode;
@synthesize authCode, avsResultCode, cvvResultCode, refTransID, transHash, transID;

- (id) init {
	self.authCode = nil;
	self.avsResultCode = nil;
	self.cvvResultCode = nil;
	self.refTransID = nil;
	self.transHash = nil;
	self.transID = nil;
	errors = [[NSMutableDictionary alloc] init];
	messages = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) dealloc {
	[authCode release];
	[avsResultCode release];
	[cvvResultCode release];
	[refTransID release];
	[transHash release];
	[transID release];
	[errors release];
	[messages release];
	[super dealloc];
}


@end
