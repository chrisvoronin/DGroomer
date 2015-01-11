//
//  CloseOut.m
//  myBusiness
//
//  Created by David J. Maier on 2/2/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "CloseOut.h"


@implementation CloseOut

@synthesize closeoutID, date, totalOwed;

- (id) init {
	closeoutID = -1;
	date = nil;
	totalOwed = nil;
	return self;
}

- (void) dealloc {
	[date release];
	[totalOwed release];
	[super dealloc];
}

@end
