//
//  WorkHoursViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface WorkHoursViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	*hoursTable;
	Settings				*settings;
}

@property (nonatomic, retain) UITableView	*hoursTable;



@end
