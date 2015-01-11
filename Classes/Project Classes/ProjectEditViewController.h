//
//  ProjectEditViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ClientTableViewController.h"
#import <UIKit/UIKit.h>

@class Project;

@interface ProjectEditViewController : UIViewController 
<PSAClientTableDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate> 
{
	// Data
	Project			*project;
	// Interface
	UITableView		*tblProject;
	// Temp for Cancel
	NSDate		*projectDateDue;
	NSString	*projectName;
	NSString	*projectNotes;
	Client		*projectClient;
}

@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) IBOutlet UITableView		*tblProject;

- (void) cancelEdit;
- (void) save;

@end
