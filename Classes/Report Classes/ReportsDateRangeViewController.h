//
//  ReportsDateRangeViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Report;

@interface ReportsDateRangeViewController : PSABaseViewController <UITableViewDataSource, UITableViewDelegate> {
	// IB elements
	IBOutlet UIDatePicker	*picker;
	IBOutlet UITableView	*tblTimes;
	IBOutlet UISwitch		*swEntire;
	//
	NSInteger	tableIndexEditing;
	//
	Report		*report;
}

@property (nonatomic, retain) UIDatePicker	*picker;
@property (nonatomic, retain) UITableView	*tblTimes;
@property (nonatomic, retain) UISwitch		*swEntire;
@property (nonatomic, retain) Report		*report;


- (IBAction)	adjustEnitreHistory:(id)sender;
- (IBAction)	dateChanged:(id)sender;
- (void)		generate;


@end
