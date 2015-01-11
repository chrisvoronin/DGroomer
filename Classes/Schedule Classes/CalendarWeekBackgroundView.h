//
//  CalendarWeekBackgroundView.h
//  PSA
//
//  Created by David J. Maier on 7/1/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalendarWeekBackgroundView : UIButton {
	NSInteger	daysDisplayed;
	id			delegate;
	NSInteger	offsetX;
	NSInteger	offsetY;
	BOOL		is15MinuteIntervals;
	Settings	*settings;
	//
	UIEvent		*lastTouch;
	CGPoint		lastTouchPoint;
	NSTimer		*touchTimer;
}

@property (nonatomic, assign) NSInteger daysDisplayed;
@property (nonatomic, assign) id		delegate;
@property (nonatomic, assign) NSInteger	offsetX;
@property (nonatomic, assign) NSInteger offsetY;
@property (nonatomic, assign) BOOL		is15MinuteIntervals;
@property (nonatomic, retain) UIEvent	*lastTouch;
@property (nonatomic, retain) Settings	*settings;

- (CGPoint) getLastTouchPoint;
- (void)	touchIsLong:(NSTimer*)theTimer;

@end
