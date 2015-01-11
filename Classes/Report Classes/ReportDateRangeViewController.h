//
//  ReportDateRangeViewController.h
//  PSA
//
//  Created by David J. Maier on 1/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReportDateRangeViewController : UIViewController {
	UIDatePicker	*datePicker;
	UITableView		*tblRanges;
}

@property (nonatomic, retain) IBOutlet UIDatePicker	*datePicker;
@property (nonatomic, retain) IBOutlet UITableView	*tblRanges;

- (void) generate;

@end
