//
//  Company.m
//  myBusiness
//
//  Created by David J. Maier on 8/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Company.h"



@implementation Company

@synthesize companyID, companyName, salesTax, companyAddress1, companyAddress2, companyCity, companyState, companyZipCode;
@synthesize companyEmail, companyPhone, companyFax, monthsOldAppointments, ownerName, commissionRate;


- (id) initWithCompanyData:(NSInteger)key name:(NSString*)compName tax:(NSNumber*)tax addr1:(NSString*)addr1 addr2:(NSString*)addr2 city:(NSString*)city state:(NSString*)state zip:(NSInteger)zip email:(NSString*)email phone:(NSString*)phone fax:(NSString*)fax appts:(NSInteger)appts owner:(NSString*)owner commissionRate:(NSNumber*)commission {
	self.companyID = key;
	self.companyName = compName;
	self.salesTax = tax;
	self.companyAddress1 = addr1;
	self.companyAddress2 = addr2;
	self.companyCity = city;
	self.companyState = state;
	self.companyZipCode = zip;
	self.companyEmail = email;
	self.companyPhone = phone;
	self.companyFax = fax;
	self.monthsOldAppointments = appts;
	self.ownerName = owner;
	self.commissionRate = commission;
	return self;
}

- (void) dealloc {
	[companyPhone release];
	[companyFax release];
	[companyName release];
	[salesTax release];
	[companyAddress1 release];
	[companyAddress2 release];
	[companyCity release];
	[companyState release];
	[companyEmail release];
	[ownerName release];
	[commissionRate release];
	[super dealloc];
}

/*
 *	No need to release this string when done.
 */
- (NSString*) getMutlilineHTMLString {
	NSMutableString *str = [[NSMutableString alloc] init];
	
	if( self.companyAddress1 ) {
		[str appendFormat:@"%@<br/>", self.companyAddress1];
	}
	if( self.companyAddress2 ) {
		[str appendFormat:@"%@<br/>", self.companyAddress2];
	}
	
	if( self.companyCity && self.companyState && self.companyZipCode > 0 ) {
		[str appendFormat:@"%@, %@ %d<br/>", self.companyCity, self.companyState, self.companyZipCode];
	} else if( self.companyCity && self.companyState ) {
		[str appendFormat:@"%@, %@<br/>", self.companyCity, self.companyState];
	} else if( self.companyCity && !self.companyState && self.companyZipCode > 0 ) {
		[str appendFormat:@"%@, %d<br/>", self.companyCity, self.companyZipCode];
	} else if( !self.companyCity && self.companyState && self.companyZipCode > 0 ) {
		[str appendFormat:@"%@, %d<br/>", self.companyState, self.companyZipCode];
	} else if( self.companyCity ) {
		[str appendFormat:@"%@<br/>", self.companyCity];
	} else if( self.companyState ) {
		[str appendFormat:@"%@<br/>", self.companyState];
	} else if( self.companyZipCode > 0 ) {
		[str appendFormat:@"%d<br/>", self.companyZipCode];
	}
	
	if( self.companyPhone ) {
		[str appendFormat:@"Phone: %@<br/>", self.companyPhone];
	}
	
	if( self.companyFax ) {
		[str appendFormat:@"Fax: %@<br/>", self.companyFax];
	}
	
	if( self.companyEmail ) {
		[str appendFormat:@"%@", self.companyEmail];
	}
	
	NSString *returnString = [NSString stringWithString:str];
	[str release];
	return returnString;
}


@end
