//
//  Settings.h
//  myBusiness
//
//  Created by David J. Maier on 8/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
	NSInteger settingsID;
	NSString *mondayStart;
	NSString *mondayFinish;
	NSString *tuesdayStart;
	NSString *tuesdayFinish;
	NSString *wednesdayStart;
	NSString *wednesdayFinish;
	NSString *thursdayStart;
	NSString *thursdayFinish;
	NSString *fridayStart;
	NSString *fridayFinish;
	NSString *saturdayStart;
	NSString *saturdayFinish;
	NSString *sundayStart;
	NSString *sundayFinish;
	BOOL isMondayOff;
	BOOL isTuesdayOff;
	BOOL isWednesdayOff;
	BOOL isThursdayOff;
	BOOL isFridayOff;
	BOOL isSaturdayOff;
	BOOL isSundayOff;
	BOOL is15MinuteIntervals;
    BOOL isCloseout;
    NSString *closeTime;
}

@property (assign, nonatomic) NSInteger settingsID;
@property (nonatomic, retain) NSString	*mondayStart;
@property (nonatomic, retain) NSString	*mondayFinish;
@property (nonatomic, retain) NSString	*tuesdayStart;
@property (nonatomic, retain) NSString	*tuesdayFinish;
@property (nonatomic, retain) NSString	*wednesdayStart;
@property (nonatomic, retain) NSString	*wednesdayFinish;
@property (nonatomic, retain) NSString	*thursdayStart;
@property (nonatomic, retain) NSString	*thursdayFinish;
@property (nonatomic, retain) NSString	*fridayStart;
@property (nonatomic, retain) NSString	*fridayFinish;
@property (nonatomic, retain) NSString	*saturdayStart;
@property (nonatomic, retain) NSString	*saturdayFinish;
@property (nonatomic, retain) NSString	*sundayStart;
@property (nonatomic, retain) NSString	*sundayFinish;

@property (nonatomic, assign) BOOL		isMondayOff;
@property (nonatomic, assign) BOOL		isTuesdayOff;
@property (nonatomic, assign) BOOL		isWednesdayOff;
@property (nonatomic, assign) BOOL		isThursdayOff;
@property (nonatomic, assign) BOOL		isFridayOff;
@property (nonatomic, assign) BOOL		isSaturdayOff;
@property (nonatomic, assign) BOOL		isSundayOff;

@property (nonatomic, assign) BOOL		is15MinuteIntervals;

@property (nonatomic, assign) BOOL		isCloseout;
@property (nonatomic, retain) NSString	*closeTime;

- (id)initWithKey:(NSInteger)key;

@end
