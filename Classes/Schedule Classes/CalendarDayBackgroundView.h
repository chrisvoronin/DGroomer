//
//  CalendarDayBackgroundView.h
//  myBusiness
//
//  Created by David J. Maier on 12/7/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface CalendarDayBackgroundView : UIButton {
	id			delegate;
	NSInteger	offsetX;
	NSInteger	offsetY;
	BOOL		is15MinuteIntervals;
	BOOL		isDayOff;
	NSString	*workHoursBegin;
	NSString	*workHoursEnd;
	//
	UIEvent		*lastTouch;
	CGPoint		lastTouchPoint;
	NSTimer		*touchTimer;
}

@property (nonatomic, assign) id		delegate;
@property (nonatomic, assign) NSInteger	offsetX;
@property (nonatomic, assign) NSInteger offsetY;
@property (nonatomic, assign) BOOL		is15MinuteIntervals;
@property (nonatomic, assign) BOOL		isDayOff;
@property (nonatomic, retain) UIEvent	*lastTouch;
@property (nonatomic, retain) NSString	*workHoursBegin;
@property (nonatomic, retain) NSString	*workHoursEnd;

- (CGPoint) getLastTouchPoint;
- (void)	touchIsLong:(NSTimer*)theTimer;

@end
