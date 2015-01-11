//
//  Report.m
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "Report.h"


@implementation Report

@synthesize dateEnd, dateStart, isEntireHistory, type;

- (id) init {
	dateEnd = nil;
	dateStart = nil;
	isEntireHistory = NO;
	type = PSAReportTypeNone;
	return self;
}

- (void) dealloc {
	[dateEnd release];
	[dateStart release];
	[super dealloc];
}


@end
