//
//  Vendor.h
//  myBusiness
//
//  Created by David J. Maier on 7/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vendor : NSObject {
	NSInteger		vendorID;
	NSString		*vendorName;
	NSString		*vendorContact;
	NSString		*vendorAddress1;
	NSString		*vendorAddress2;
	NSString		*vendorCity;
	NSString		*vendorState;
	NSInteger		vendorZipcode;
	NSString		*vendorTelephone;
	NSString		*vendorEmail;
	NSString		*vendorFax;
}


@property (assign, nonatomic) NSInteger		vendorID;
@property (assign, nonatomic) NSInteger		vendorZipcode;

@property (nonatomic, retain) NSString		*vendorName;
@property (nonatomic, retain) NSString		*vendorContact;
@property (nonatomic, retain) NSString		*vendorAddress1;
@property (nonatomic, retain) NSString		*vendorAddress2;
@property (nonatomic, retain) NSString		*vendorCity;
@property (nonatomic, retain) NSString		*vendorState;
@property (nonatomic, retain) NSString		*vendorEmail;
@property (nonatomic, retain) NSString		*vendorTelephone;
@property (nonatomic, retain) NSString		*vendorFax;



- (id)	init;
- (id)	initWithVendorData:(NSInteger)vID name:(NSString*)vName contact:(NSString*)vContact addr1:(NSString*)vAddr1 addr2:(NSString*)vAddr2 city:(NSString*)vCity state:(NSString*)vState zip:(NSInteger)vZip phone:(NSString*)vPhone email:(NSString*)vEmail fax:(NSString*)vFax;

@end
