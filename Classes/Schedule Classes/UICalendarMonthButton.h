//
//  UICalendarMonthButton.h
//  myBusiness
//
//  Created by David J. Maier on 11/27/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UICalendarMonthButton : UIButton {
	BOOL		appointmentsInAfternoon;
	BOOL		appointmentsInMorning;
	NSString	*dayNumber;
	NSInteger	rowNumber;
}

@property (nonatomic, assign) BOOL		appointmentsInAfternoon;
@property (nonatomic, assign) BOOL		appointmentsInMorning;
@property (nonatomic, retain) NSString	*dayNumber;
@property (nonatomic, assign) NSInteger	rowNumber;

- (void) drawAppointmentNotifiersInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawAppointmentNotifiersSelectedInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawHighlightedTextInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawNormalInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawNormalTextInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawSelectedInContext:(CGContextRef)context frame:(CGRect)theFrame;
- (void) drawSelectedTextInContext:(CGContextRef)context frame:(CGRect)theFrame;

@end
