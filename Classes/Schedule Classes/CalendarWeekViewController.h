//
//  CalendarWeekViewController.h
//  PSA
//
//  Created by David J. Maier on 7/1/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class CalendarWeekBackgroundView, ScheduleViewController, Settings;

@interface CalendarWeekViewController : UIViewController <PSADataManagerDelegate> {
	IBOutlet CalendarWeekBackgroundView	*btnBackground;
	
	NSArray					*appointments;	// Actually a mutable array
	NSCalendar				*calendar;
	NSDate					*currentDate;
	BOOL					firstLoad;
	BOOL					isThisWeek;
	IBOutlet UILabel		*lbHeader;
	UINavigationController	*parentsNavigationController;
	CGFloat					pixelsPerHour;
	ScheduleViewController	*scheduleViewController;
	IBOutlet UIScrollView	*scrollView;
	Settings				*settings;
	
	IBOutlet UILabel	*lbSunday;
	IBOutlet UILabel	*lbMonday;
	IBOutlet UILabel	*lbTuesday;
	IBOutlet UILabel	*lbWednesday;
	IBOutlet UILabel	*lbThursday;
	IBOutlet UILabel	*lbFriday;
	IBOutlet UILabel	*lbSaturday;
}

@property (nonatomic, retain) CalendarWeekBackgroundView	*btnBackground;
@property (nonatomic, retain) NSDate						*currentDate;
@property (nonatomic, retain) UILabel						*lbHeader;
@property (nonatomic, retain) UINavigationController		*parentsNavigationController;
@property (nonatomic, retain) ScheduleViewController		*scheduleViewController;
@property (nonatomic, retain) UIScrollView					*scrollView;

@property (nonatomic, retain) UILabel	*lbSunday;
@property (nonatomic, retain) UILabel	*lbMonday;
@property (nonatomic, retain) UILabel	*lbTuesday;
@property (nonatomic, retain) UILabel	*lbWednesday;
@property (nonatomic, retain) UILabel	*lbThursday;
@property (nonatomic, retain) UILabel	*lbFriday;
@property (nonatomic, retain) UILabel	*lbSaturday;

- (void)		addAppointment:(Appointment*)theAppt;
- (void)		drawAppointments;
- (NSDate*)		getDateForEvent:(UIEvent*)theEvent;
- (void)		goToAppointment:(id)sender forEvent:(UIEvent*)event;
- (IBAction)	goToLastWeek:(id)sender;
- (IBAction)	goToNextWeek:(id)sender;
- (void)		goToToday;
- (BOOL)		hasAppointment:(Appointment*)theAppt;
- (void)		redraw;

@end
