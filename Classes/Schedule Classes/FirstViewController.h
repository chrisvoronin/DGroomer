//
//  FirstViewController.h
//  PSA
//
//  Created by Michael Simone on 3/5/09.
//  Copyright Dropped Pin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DayViewController.h"
#import "WeekViewController.h"
#import "MonthViewController.h"
#import "AppointmentViewController.h"
#import "AddApptController.h"

@interface FirstViewController : UIViewController {
	DayViewController	*dayController;
	WeekViewController	*weekController;
	MonthViewController	*monthController;
	AppointmentViewController	*apptController;
	AddApptController	*addApptController;
}

@property (nonatomic, retain) DayViewController		*dayController;
@property (nonatomic, retain) WeekViewController	*weekController;
@property (nonatomic, retain) MonthViewController	*monthController;
@property (nonatomic, retain) AppointmentViewController *apptController;
@property (nonatomic, retain) AddApptController	*addApptController;

+ (FirstViewController *) FirstViewSharedController;
- (IBAction)getCalendarEvent:(id)sender;
- (IBAction)getCurrentDay:(id)sender;

- (void)loadControllers;
- (NSString*)getCalendarDay;

- (IBAction)cancel:(id)sender;

@end
