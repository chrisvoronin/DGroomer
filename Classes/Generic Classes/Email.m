//
//  Email.m
//  myBusiness
//
//  Created by David J. Maier on 2/28/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "Email.h"

@implementation Email

@synthesize bccCompany, emailID, message, subject, type;

- (id) init {
	emailID = -1;
	bccCompany = NO;
	message = nil;
	subject = nil;
	return self;
}

- (void) dealloc {
	[message release];
	[subject release];
	[super dealloc];
}

@end
