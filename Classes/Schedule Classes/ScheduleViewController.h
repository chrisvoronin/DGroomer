//
//  ScheduleViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppointmentViewController.h"

@class Appointment, CalendarDayViewController, CalendarListViewController, CalendarMonthViewController, CalendarWeekViewController;

@interface ScheduleViewController : PSABaseViewController<AppointmentViewDelegate, MFMailComposeViewControllerDelegate> {
	// Interface Elements
	IBOutlet UIView				*calendarView;
	UIView						*landscapeView;
	IBOutlet UISegmentedControl	*segCalendarType;
	IBOutlet UIToolbar			*toolbar;
	// Date structures
	NSDate						*currentDate;
	// View Controllers
	CalendarDayViewController	*dayController;
	CalendarListViewController	*listController;
	CalendarMonthViewController	*monthController;
	CalendarWeekViewController	*weekController;
	// "Pasteboard"
	Appointment	*activeAppointment;
	// Other
	BOOL	firstTime;
	BOOL	isShowingLandscapeView;
}

@property (nonatomic, retain) Appointment			*activeAppointment;
@property (nonatomic, retain) UIView				*calendarView;
@property (nonatomic, retain) NSDate				*currentDate;
@property (nonatomic, retain) UISegmentedControl	*segCalendarType;
@property (nonatomic, retain) UIToolbar				*toolbar;


- (void)		addAppointment;
- (void)		copyAppointment:(Appointment*)appt;
- (void)		cutAppointment:(Appointment*)appt;
- (IBAction)	getCalendarEvent:(id)sender;
- (IBAction)	goToToday:(id)sender;
- (void)		pasteAppointmentToDate:(NSDate*)date;


@end
