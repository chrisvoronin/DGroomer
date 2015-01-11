//
//  ScheduleViewController.h
//  myBusiness
//
//  Created by David J. Maier on 6/26/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Appointment;

@interface AppointmentDatePickerViewController : PSABaseViewController {
    IBOutlet UIDatePicker	*datePicker;
	Appointment				*appointment;
	//
	IBOutlet UILabel			*lbDate;
	IBOutlet UISegmentedControl	*segPicker;
}

@property (nonatomic, retain) Appointment			*appointment;
@property (nonatomic, retain) UIDatePicker			*datePicker;
@property (nonatomic, retain) UILabel				*lbDate;
@property (nonatomic, retain) UISegmentedControl	*segPicker;

- (IBAction)	datePickerChanged:(id)sender;
- (void) 		done;
- (IBAction)	segPickerChanged:(id)sender;
- (void)		updateLabel;

@end

