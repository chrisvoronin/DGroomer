//
//  ProductType.m
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//


#import "ProductType.h"

@implementation ProductType 

@synthesize typeDescription, typeID;

- (id) init {
	typeID = -1;
	typeDescription = nil;
	return self;
}

- (id) initWithTypeData:(NSString *)tp key:(NSInteger)key {
	self.typeDescription = tp;
	self.typeID = key;
	
	return self;
}

- (void) dealloc {
	[typeDescription release];
	[super dealloc];
}

@end
