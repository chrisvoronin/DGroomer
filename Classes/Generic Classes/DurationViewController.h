//
//  ServiceTimeController.h
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Appointment, Service;

@interface DurationViewController : PSABaseViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource> {
	// IB elements
	IBOutlet UIPickerView	*picker;
	IBOutlet UITableView	*tblTimes;
	// Labels overlayed on the picker to mimic Apple's "Clock" app functionality
	IBOutlet UILabel		*lbHours;
	IBOutlet UILabel		*lbMinutes;
	// Our Data objects
	Appointment				*appointment;
	Service					*service;
	// Keep track of the values before a save
	NSInteger	startInSeconds;
	NSInteger	tableIndexEditing;
	// Value arrays
	NSMutableArray	*minuteArray;
	NSMutableArray	*hourArray;
}

@property (nonatomic, retain) UIPickerView	*picker;
@property (nonatomic, retain) UITableView	*tblTimes;
@property (nonatomic, retain) UILabel		*lbHours;
@property (nonatomic, retain) UILabel		*lbMinutes;
@property (nonatomic, retain) Appointment	*appointment;
@property (nonatomic, retain) Service		*service;
@property (nonatomic, assign) NSInteger		tableIndexEditing;


- (void)		done;
- (void)		selectRowsInPicker;

@end
