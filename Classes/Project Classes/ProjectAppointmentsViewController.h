//
//  ProjectAppointmentsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/24/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class Appointment, Project;

@interface ProjectAppointmentsViewController : UIViewController <PSADataManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
	Project			*project;
	UITableView		*tblAppointments;
}

@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) IBOutlet UITableView		*tblAppointments;

- (void) add;
- (void) reload;

@end
