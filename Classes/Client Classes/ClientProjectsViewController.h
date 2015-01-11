//
//  ClientFormulaViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import "PSADataManager.h"
#import <UIKit/UIKit.h>


@interface ClientProjectsViewController : GenericClientDetailViewController <PSADataManagerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSNumberFormatter	*formatter;
	UITableViewCell		*projectsTableCell;
	UITableView			*tblProjects;
	NSArray				*projects;
}

@property (nonatomic, assign) UITableViewCell		*projectsTableCell;
@property (nonatomic, retain) IBOutlet UITableView	*tblProjects;

- (void) addButtonTouchUp;

@end
