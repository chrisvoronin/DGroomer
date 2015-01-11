//
//  ProjectServicesViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ServicesTableViewController.h"
#import <UIKit/UIKit.h>

@class Project;

@interface ProjectServicesViewController : UIViewController 
<PSAServiceTableDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
	NSNumberFormatter	*formatter;
	Project			*project;
	UITableView		*tblServices;
	UITableViewCell	*cellService;
	//
	ProjectService	*toDelete;
	//

}

@property (nonatomic, assign) IBOutlet UITableViewCell	*cellService;
@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) IBOutlet UITableView		*tblServices;

- (void)		add;
- (void)		deleteService;
- (IBAction)	goToTimer:(id)sender;


@end
