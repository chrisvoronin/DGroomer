//
//  UIAppointmentButton.h
//  myBusiness
//
//  Created by David J. Maier on 11/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Appointment;

@interface UIAppointmentButton : UIButton {
	Appointment	*appointment;
	id			delegate;
	BOOL		isWeekAppointment;
	CGFloat		pixelsPerMinute;
	BOOL		positionFixed;
	NSInteger	column;
	NSInteger	totalColumns;
	//
	NSTimer		*touchTimer;
}

@property (nonatomic, retain) Appointment	*appointment;
@property (nonatomic, assign) id			delegate;
@property (nonatomic, assign) BOOL			isWeekAppointment;
@property (nonatomic, assign) NSInteger		column;
@property (nonatomic, assign) CGFloat		pixelsPerMinute;
@property (nonatomic, assign) BOOL			positionFixed;
@property (nonatomic, assign) NSInteger		totalColumns;

- (void) drawRoundedRectInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawRoundedRectWithTextInContext:(CGContextRef)context frame:(CGRect)theFrame;

- (BOOL) overlapsWithFrame:(CGRect)theFrame;
- (BOOL) touchInGapWithEvent:(UIEvent*)theEvent;
- (void) touchIsLong:(NSTimer*)theTimer;

@end
