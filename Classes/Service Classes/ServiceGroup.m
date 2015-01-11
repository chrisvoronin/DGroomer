//
//  Group.m
//  myBusiness
//
//  Created by David J. Maier on 6/12/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "ServiceGroup.h"

@implementation ServiceGroup 

@synthesize groupDescription, groupID;

- (id) init {
	self.groupID = -1;
	self.groupDescription = nil;
	return self;
}

- (id) initWithGroupData:(NSString *)gp key:(int)key{
	self.groupDescription = gp;
	self.groupID = key;
	return self;
}

- (void) dealloc {
	[groupDescription release];
	[super dealloc];
}

@end
