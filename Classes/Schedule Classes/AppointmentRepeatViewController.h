//
//  AppointmentRepeatViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/19/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Appointment;

@interface AppointmentRepeatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	Appointment				*appointment;
	IBOutlet UITableView	*tblRepeat;
}

@property (nonatomic, retain) Appointment	*appointment;
@property (nonatomic, retain) UITableView	*tblRepeat;


@end
