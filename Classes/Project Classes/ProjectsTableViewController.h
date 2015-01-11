//
//  ProjectsTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/17/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

// Protocol Definition
@protocol iBizProjectTableDelegate <NSObject>
@required
- (void) selectionMadeWithProject:(Project*)theProject;
@end

@interface ProjectsTableViewController : UIViewController 
<iBizProjectTableDelegate, PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	// Other
	NSNumberFormatter	*formatter;
	id					projectsDelegate;
	BOOL				dontAllowNewProject;
	// Project Datas
	NSDictionary		*projects;  // sorted by last modified date
	NSIndexPath			*projectToDelete;
	NSArray				*sortedKeys;
	// Search
	NSMutableArray		*filteredList;
	UITableView			*tableDeleting;
	// Interface
	UITableViewCell		*projectsTableCell;
	UISegmentedControl	*segProjectType;
	UITableView			*tblProjects;
}

@property (nonatomic, assign) id <iBizProjectTableDelegate>	projectsDelegate;
@property (nonatomic, assign) BOOL							dontAllowNewProject;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segProjectType;
@property (nonatomic, retain) IBOutlet UITableView			*tblProjects;
@property (nonatomic, assign) IBOutlet UITableViewCell		*projectsTableCell;

- (void)		addProject;
- (void)		releaseAndRepopulateProjects;
- (IBAction)	segProjectTypeChanged:(id)sender;
- (void)		setSortedKeys;

@end
