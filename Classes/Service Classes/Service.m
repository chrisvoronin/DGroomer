//
//  Service.m
//  myBusiness
//
//  Created by David J. Maier on 7/11/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Service.h"


@implementation Service

@synthesize serviceID, groupID, groupName, serviceName, servicePrice, serviceCost, taxable, duration, isActive, serviceIsFlatRate, serviceSetupFee;
@synthesize color;


- (id) init {
	self.serviceID = -1;
	self.groupID = -1;
	self.isActive = YES;
	self.serviceIsFlatRate = NO;
	[self setColorWithString:@"0::0::0"];
	return self;
}

- (id)initWithServiceData:(NSInteger)servID gID:(NSInteger)gID servName:(NSString*)servName price:(NSNumber*)p cost:(NSNumber*)c taxabe:(NSInteger)t duration:(NSInteger)s {
	self.serviceID = servID;
	self.groupID = gID;
	self.serviceName = servName;
	self.servicePrice = p;
	self.serviceCost = c;
	self.taxable = t;
	self.duration = s;
	return self;
}

- (void) dealloc {
	[color release];
	[serviceName release];
	[serviceCost release];
	[servicePrice release];
	[groupName release];
	[serviceSetupFee release];
	[super dealloc];
}


- (void) setColorWithString:(NSString*)colorString {
	// I separate RGB values by :: delimiter (i.e. '%f::%f::%f')
	NSArray *colors = [colorString componentsSeparatedByString:@"::"];
	if( color )	[color release];
	color = [[UIColor alloc] initWithRed:[[colors objectAtIndex:0] floatValue] green:[[colors objectAtIndex:1] floatValue] blue:[[colors objectAtIndex:2] floatValue] alpha:.7];
}

@end
