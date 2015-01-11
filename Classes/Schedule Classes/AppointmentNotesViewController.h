//
//  AppointmentNotesViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/19/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Appointment;

@interface AppointmentNotesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	BOOL					isEditable;
	IBOutlet UITableView	*tblNotes;
	UITextView				*txtNotes;
	Appointment				*appointment;
}

@property (nonatomic, retain) Appointment	*appointment;
@property (nonatomic, assign) BOOL			isEditable;
@property (nonatomic, retain) UITableView	*tblNotes;
@property (nonatomic, retain) UITextView	*txtNotes;

- (void) done;

@end
