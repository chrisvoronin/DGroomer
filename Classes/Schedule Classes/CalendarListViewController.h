//
//  CalendarListViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/24/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@interface CalendarListViewController : UIViewController <PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableViewCell	*appointmentCell;
	NSMutableArray				*headerViews;
	UINavigationController		*parentsNavigationController;
	IBOutlet UITableView		*tblList;
	// Data
	NSDictionary				*appointments;
	NSArray						*sortedKeys;
}

@property (nonatomic, assign) UITableViewCell			*appointmentCell;
@property (nonatomic, retain) UINavigationController	*parentsNavigationController;
@property (nonatomic, retain) UITableView				*tblList;

- (void) goToToday;

@end
