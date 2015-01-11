//
//  UnapprovedEstimatesTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 4/9/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>


@interface UnapprovedEstimatesTableViewController : UIViewController <PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSArray				*estimates;
	UITableViewCell		*estimateCell;
	NSNumberFormatter	*formatter;
	UITableView			*tblEstimates;
}

@property (nonatomic, retain) IBOutlet UITableViewCell	*estimateCell;
@property (nonatomic, retain) IBOutlet UITableView		*tblEstimates;

- (void) releaseAndRepopulateEstimates;

@end
