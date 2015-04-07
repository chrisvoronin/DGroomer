//
//  Settings.m
//  myBusiness
//
//  Created by David J. Maier on 8/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "Settings.h"


@implementation Settings

@synthesize settingsID;
@synthesize mondayStart, mondayFinish, tuesdayStart, tuesdayFinish;
@synthesize wednesdayStart, wednesdayFinish, thursdayStart, thursdayFinish, fridayStart, fridayFinish, saturdayStart, saturdayFinish;
@synthesize sundayStart, sundayFinish;
@synthesize isMondayOff, isTuesdayOff, isWednesdayOff, isThursdayOff, isFridayOff, isSaturdayOff, isSundayOff;
@synthesize is15MinuteIntervals;
@synthesize isCloseout, closeTime;

- (id)initWithKey:(NSInteger)key {
	self.settingsID = key;
	return self;
}

- (void) dealloc {
	[mondayStart release];
	[tuesdayStart release];
	[wednesdayStart release];
	[thursdayStart release];
	[fridayStart release];
	[saturdayStart release];
	[sundayStart release];
	[mondayFinish release];
	[tuesdayFinish release];
	[wednesdayFinish release];
	[thursdayFinish release];
	[fridayFinish release];
	[saturdayFinish release];
	[sundayFinish release];
    [closeTime release];
	[super dealloc];
}

@end
