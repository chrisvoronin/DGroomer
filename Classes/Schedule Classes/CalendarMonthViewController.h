//
//  MonthViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class UICalendarMonthButton;

@interface CalendarMonthViewController : UIViewController <PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	// Views
	IBOutlet UITableViewCell	*appointmentCell;
	IBOutlet UITableViewCell	*calendarMonthCell;
	IBOutlet UILabel			*lbHeader;
	UINavigationController		*parentsNavigationController;
	UICalendarMonthButton		*currentSelection;
	IBOutlet UITableView		*tblCalendar;
	IBOutlet UITableView		*tblList;
	// Data
	NSDictionary				*appointments;
	NSCalendar					*calendar;
	NSDate						*currentDate;
	NSDate						*currentMonth;
	//
	// Weekday Labels
	IBOutlet UILabel			*lbSunday;
	IBOutlet UILabel			*lbMonday;
	IBOutlet UILabel			*lbTuesday;
	IBOutlet UILabel			*lbWednesday;
	IBOutlet UILabel			*lbThursday;
	IBOutlet UILabel			*lbFriday;
	IBOutlet UILabel			*lbSaturday;
	//
	BOOL	firstLoad;
}

@property (nonatomic, assign) UITableViewCell			*appointmentCell;
@property (nonatomic, assign) UITableViewCell			*calendarMonthCell;
@property (nonatomic, retain) NSDate					*currentDate;
@property (nonatomic, retain) NSDate					*currentMonth;
@property (nonatomic, retain) UILabel					*lbHeader;
@property (nonatomic, retain) UINavigationController	*parentsNavigationController;
@property (nonatomic, retain) UITableView				*tblCalendar;
@property (nonatomic, retain) UITableView				*tblList;

@property (nonatomic, retain) UILabel	*lbSunday;
@property (nonatomic, retain) UILabel	*lbMonday;
@property (nonatomic, retain) UILabel	*lbTuesday;
@property (nonatomic, retain) UILabel	*lbWednesday;
@property (nonatomic, retain) UILabel	*lbThursday;
@property (nonatomic, retain) UILabel	*lbFriday;
@property (nonatomic, retain) UILabel	*lbSaturday;

- (IBAction)	btnTouched:(id)sender;
- (IBAction)	goToNextMonthWithDayNumber:(NSInteger)num;
- (IBAction)	goToPreviousMonthWithDayNumber:(NSInteger)num;
- (void)		goToToday;

@end
