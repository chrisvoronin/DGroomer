//
//  SetDailyHoursViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

typedef enum DailyHoursDayOfTheWeek {
	DailyHoursDayOfTheWeekSunday,
	DailyHoursDayOfTheWeekMonday,
	DailyHoursDayOfTheWeekTuesday,
	DailyHoursDayOfTheWeekWednesday,
	DailyHoursDayOfTheWeekThursday,
	DailyHoursDayOfTheWeekFriday,
	DailyHoursDayOfTheWeekSaturday
} DailyHoursDayOfTheWeek;

@class Settings;

@interface SetDailyHoursViewController : PSABaseViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	*hoursTable;
	IBOutlet UIDatePicker	*timePicker;
	Settings				*settings;
	DailyHoursDayOfTheWeek	dayOfTheWeek;
	NSDate					*start;
	NSDate					*finish;
	int						tableIndexEditing;
	BOOL					dayIsOff;
}

@property (nonatomic, retain) UITableView	*hoursTable;
@property (nonatomic, retain) UIDatePicker	*timePicker;
@property (nonatomic, retain) Settings		*settings;
@property (nonatomic, assign) DailyHoursDayOfTheWeek	dayOfTheWeek;
@property (nonatomic, assign) BOOL			dayIsOff;

- (void)		cancel;
- (void)		save;
- (IBAction)	timeChanged:(id)sender;
- (void)		toggleOffDay;

@end
