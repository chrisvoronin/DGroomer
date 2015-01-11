//
//  CreditCardPayment.m
//  PSA
//
//  Created by David J. Maier on 5/3/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "Client.h"
#import "CreditCardResponse.h"
#import "CreditCardPayment.h"


@implementation CreditCardPayment

@synthesize ccPaymentID, client, ccCVV, ccExpirationMonth, ccExpirationYear, ccNumber;
@synthesize amount, tip;
@synthesize date, response, milestoneStatus, status;
@synthesize clientEmail, clientPhone, nameFirst, nameMiddle, nameLast, notes;
@synthesize addressStreet, addressCity, addressState, addressZip;

- (id) init {
	conn = nil;
	self.client = nil;
	self.clientEmail = nil;
	self.clientPhone = nil;
	self.nameFirst = nil;
	self.nameMiddle = nil;
	self.nameLast = nil;
	self.addressStreet = nil;
	self.addressCity = nil;
	self.addressState = nil;
	self.addressZip = nil;
	self.ccPaymentID = -1;
	self.ccCVV = nil;
	self.ccExpirationMonth = nil;
	self.ccExpirationYear = nil;
	self.ccNumber = nil;
	self.amount = nil;
	self.tip = nil;
	milestoneStatus = CreditCardProcessingNotProcessed;
	self.status = CreditCardProcessingNotProcessed;
	self.date = nil;
	self.response = nil;
	return self;
}

- (void) dealloc {
	[conn release];
	[client release];
	[clientEmail release];
	[clientPhone release];
	[nameFirst release];
	[nameMiddle release];
	[nameLast release];
	[notes release];
	[addressStreet release];
	[addressCity release];
	[addressState release];
	[addressZip release];
	[ccCVV release];
	[ccExpirationMonth release];
	[ccExpirationYear release];
	[ccNumber release];
	[amount release];
	[tip release];
	[date release];
	[response release];
	[super dealloc];
}

- (void) cancel {
	if( conn ) {
		if( status == CreditCardProcessingConnecting ) {
			[conn cancel];
		}
	}
}

- (void) chargeWithDelegate:(id)theDelegate {
	milestoneStatus = status;
	if( conn ) {
		[conn release];
		conn = nil;
	}
	conn = [[CreditCardConnectionManager alloc] init];
	conn.ccPayment = self;
	conn.delegate = theDelegate;
	[conn charge];
}

- (void) extractDataFromClientContact {
	self.nameFirst = [client getFirstName];
	self.nameLast = [client getLastName];
	// Use cell, home, work, or any phone # found... in that order
	NSString *x_phone = [client getPhoneCell];
	if( x_phone == nil ) {
		x_phone = [client getPhoneHome];		
		if( x_phone == nil ) {
			x_phone = [client getPhoneWork];
			if( x_phone == nil ) {
				x_phone = [client getPhoneAny];
			}
		}
	}
	self.clientPhone = x_phone;
	[x_phone release];
	// Email... home, work, any
	NSString *x_email = [client getEmailAddressHome];
	if( x_email == nil ) {
		x_email = [client getEmailAddressWork];
		if( x_email == nil ) {
			x_email = [client getEmailAddressAny];
		}
	}
	self.clientEmail = x_email;
	[x_email release];
	
	NSDictionary *address = [client getAddressAny];
	self.addressStreet = (NSString*)[address objectForKey:(NSString*)kABPersonAddressStreetKey];
	self.addressCity = (NSString*)[address objectForKey:(NSString*)kABPersonAddressCityKey];
	self.addressState = (NSString*)[address objectForKey:(NSString*)kABPersonAddressStateKey];
	self.addressZip = (NSString*)[address objectForKey:(NSString*)kABPersonAddressZIPKey];
	[address release];
}

- (NSString*) getCityStateZip {
	NSString *str = nil;
	if( self.addressCity && self.addressState && self.addressZip ) {
		str = [NSString stringWithFormat:@"%@, %@ %@", self.addressCity, self.addressState, self.addressZip];
	} else if( self.addressCity && self.addressState ) {
		str = [NSString stringWithFormat:@"%@, %@", self.addressCity, self.addressState];
	} else if( self.addressCity && self.addressZip ) {
		str = [NSString stringWithFormat:@"%@, %@", self.addressCity, self.addressZip];
	} else if( self.addressState && self.addressZip ) {
		str = [NSString stringWithFormat:@"%@ %@", self.addressState, self.addressZip];
	} else if( self.addressCity ) {
		str = [NSString stringWithFormat:@"%@", self.addressCity];
	} else if( self.addressState ) {
		str = [NSString stringWithFormat:@"%@", self.addressState];
	} else if( self.addressZip ) {
		str = [NSString stringWithFormat:@"%@", self.addressZip];
	}
	return str;
}

- (NSString*) getName {
	NSString *str = nil;
	if( self.nameFirst && self.nameMiddle && self.nameLast ) {
		str = [NSString stringWithFormat:@"%@ %@ %@", self.nameFirst, self.nameMiddle, self.nameLast];
	} else if( self.nameFirst && self.nameLast ) {
		str = [NSString stringWithFormat:@"%@ %@", self.nameFirst, self.nameLast];
	} else if( self.nameFirst ) {
		str = [NSString stringWithFormat:@"%@", self.nameFirst];
	} else if( self.nameLast ) {
		str = [NSString stringWithFormat:@"%@", self.nameLast];
	} else {
		str = @"No Name";
	}
	return str;
}

- (void) refundWithDelegate:(id)theDelegate {
	milestoneStatus = CreditCardProcessingApproved;
	if( conn ) {
		[conn release];
		conn = nil;
	}
	conn = [[CreditCardConnectionManager alloc] init];
	conn.ccPayment = self;
	conn.delegate = theDelegate;
	[conn refund];
}

- (void) resetStatus {
	status = milestoneStatus;
}

- (void) voidWithDelegate:(id)theDelegate {
	milestoneStatus = CreditCardProcessingApproved;
	if( conn ) {
		[conn release];
		conn = nil;
	}
	conn = [[CreditCardConnectionManager alloc] init];
	conn.ccPayment = self;
	conn.delegate = theDelegate;
	[conn voidTransaction];
}

@end
