//
//  DayViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/18/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class CalendarDayBackgroundView, ScheduleViewController, Settings;

@interface CalendarDayViewController : UIViewController <PSADataManagerDelegate> {
	IBOutlet CalendarDayBackgroundView	*btnBackground;
	
	NSArray					*appointments;	// Actually a mutable array
	NSCalendar				*calendar;
	NSDate					*currentDate;
	BOOL					firstLoad;
	BOOL					isToday;
	IBOutlet UILabel		*lbDayHeader;
	IBOutlet UILabel		*lbMonthHeader;
	UINavigationController	*parentsNavigationController;
	CGFloat					pixelsPerHour;
	ScheduleViewController	*scheduleViewController;
	IBOutlet UIScrollView	*scrollView;
	Settings				*settings;
}

@property (nonatomic, retain) CalendarDayBackgroundView	*btnBackground;
@property (nonatomic, retain) NSDate					*currentDate;
@property (nonatomic, retain) UILabel					*lbDayHeader;
@property (nonatomic, retain) UILabel					*lbMonthHeader;
@property (nonatomic, retain) UINavigationController	*parentsNavigationController;
@property (nonatomic, retain) ScheduleViewController	*scheduleViewController;
@property (nonatomic, retain) UIScrollView				*scrollView;

- (void)		addAppointment:(Appointment*)theAppt;
- (void)		drawAppointments;
- (NSDate*)		getDateForEvent:(UIEvent*)theEvent;
- (void)		goToAppointment:(id)sender forEvent:(UIEvent*)event;
- (void)		goToToday;
- (IBAction)	goToTomorrow:(id)sender;
- (IBAction)	goToYesterday:(id)sender;
- (BOOL)		hasAppointment:(Appointment*)theAppt;

@end
