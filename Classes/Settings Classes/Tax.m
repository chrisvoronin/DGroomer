//
//  Tax.m
//  myBusiness
//
//  Created by David J. Maier on 8/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Tax.h"


@implementation Tax

@synthesize taxID, taxName, taxDescription, taxRate, isPercentage, commissionRate;

- (id)initWithTaxData:(NSInteger)key name:(NSString*)name desc:(NSString*)desc rate:(NSNumber*)rate pct:(NSInteger)pct comm:(NSNumber*)comm {
	self.taxID = key;
	self.taxName = name;
	self.taxDescription = desc;
	self.taxRate = rate;
	self.isPercentage = pct;
	self.commissionRate = comm;
	return self;
}

@end
