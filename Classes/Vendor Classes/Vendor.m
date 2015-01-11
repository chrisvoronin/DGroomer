//
//  Vendor.m
//  myBusiness
//
//  Created by David J. Maier on 7/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Vendor.h"


@implementation Vendor

@synthesize vendorID, vendorName, vendorContact, vendorAddress1, vendorAddress2, vendorCity, vendorState, vendorZipcode, vendorTelephone, vendorEmail, vendorFax;

- (id) init {
	self.vendorID = -1;
	return self;
}

- (id) initWithVendorData:(NSInteger)vID name:(NSString*)vName contact:(NSString*)vContact addr1:(NSString*)vAddr1 addr2:(NSString*)vAddr2 city:(NSString*)vCity state:(NSString*)vState zip:(NSInteger)vZip phone:(NSString*)vPhone email:(NSString*)vEmail fax:(NSString*)vFax {
	self.vendorID = vID;
	self.vendorName = vName;
	self.vendorContact = vContact;
	self.vendorAddress1 = vAddr1;
	self.vendorAddress2 = vAddr2;
	self.vendorCity = vCity;
	self.vendorState = vState;
	self.vendorZipcode = vZip;
	self.vendorTelephone = vPhone;
	self.vendorEmail = vEmail;
	self.vendorFax = vFax;
	return self;
}

- (void) dealloc {
	[vendorName release];
	[vendorContact release];
	[vendorAddress1 release];
	[vendorAddress2 release];
	[vendorCity release];
	[vendorState release];
	[vendorEmail release];
	[vendorTelephone release];
	[vendorFax release];
	[super dealloc];
}

@end
