//
//  AppointmentRepeatUntilViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@interface AppointmentRepeatUntilViewController : PSABaseViewController {
	IBOutlet UIDatePicker	*datePicker;
	Appointment				*appointment;
}

@property (nonatomic, retain) Appointment	*appointment;
@property (nonatomic, retain) UIDatePicker	*datePicker;

- (void) done;

@end
