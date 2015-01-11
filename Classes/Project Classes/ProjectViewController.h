//
//  ProjectViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

@interface ProjectViewController : UIViewController <UIActionSheetDelegate> {
	// Data
	NSNumberFormatter	*formatter;
	Project				*project;
	// Interface
	UITableViewCell	*projectButtonsCell;
	UITableViewCell	*projectInformationCell;
	UITableViewCell	*projectItemsCell;
	UITableViewCell	*projectNotesCell;
	UITableViewCell	*projectPaymentItemsCell;
	UITableViewCell	*projectValue2Cell;
	UITableView		*tblProject;

}

@property (nonatomic, retain) Project					*project;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectButtonsCell;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectInformationCell;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectItemsCell;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectNotesCell;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectPaymentItemsCell;
@property (nonatomic, assign) IBOutlet UITableViewCell	*projectValue2Cell;
@property (nonatomic, retain) IBOutlet UITableView		*tblProject;

- (IBAction)	completeProject:(id)sender;
- (IBAction)	deleteProject:(id)sender;
- (void)		edit;


@end
