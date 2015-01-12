//
//  ClientFormulaViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Project.h"
#import "ProjectViewController.h"
#import "ProjectEditViewController.h"
#import "ClientProjectsViewController.h"


@implementation ClientProjectsViewController

@synthesize projectsTableCell, tblProjects;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle { 
    self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) {
        self.title = @"Projects";
		self.tabBarItem.image = [UIImage imageNamed:@"iconFormulations.png"];
		//
    } 
    return self; 
} 


- (void) viewDidLoad {
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouchUp)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	// Get the Formulas
	if( client ) {
		[self.view setUserInteractionEnabled:NO];
		[[PSADataManager sharedInstance] showActivityIndicator];
		[[PSADataManager sharedInstance] setDelegate:self];
		[[PSADataManager sharedInstance] getArrayOfProjectsForClient:client];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[formatter release];
	self.tblProjects = nil;
	[projects release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (void) addButtonTouchUp {	
	// New Project
	Project *new = [[Project alloc] init];
	new.client = client;
	// ViewController
	ProjectEditViewController *pvc = [[ProjectEditViewController alloc] initWithNibName:@"ProjectEditView" bundle:nil];
	pvc.project = new;
	[new release];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	pvc.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[pvc release];
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	if( projects )	[projects release];
	projects = [theArray retain];
	[tblProjects reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -

/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Clicked the ... button
	
}

#pragma mark -
#pragma mark TableView Delegate and DataSource Methods
#pragma mark -

/*
 *	Returns the number of formulas for the client
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return projects.count;
}

/*
 *	The number of sections, just 1
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ProjectsTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"ProjectsTableCell" owner:self options:nil];
		cell = projectsTableCell;
		self.projectsTableCell = nil;
    }
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusClient = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	Project *tmpProject = [projects objectAtIndex:indexPath.row];
	
	if( tmpProject ) {
		lbName.text = tmpProject.name;
		
		NSString *status = @"OPEN";
		if( tmpProject.dateCompleted != nil ) {
			status = @"COMPLETE";
		}
	
		NSString *due = nil;
		if( tmpProject.dateDue ) {
			due = [[NSString alloc] initWithFormat:@" - Due %@", [[PSADataManager sharedInstance] getStringForDate:tmpProject.dateDue withFormat:NSDateFormatterShortStyle]];
		} else {
			due = [[NSString alloc] initWithString:@""];
		}
		
		NSString *detailText = [[NSString alloc] initWithFormat:@"%@%@", status, due];
		[due release];
		lbStatusClient.text = detailText;
		[detailText release];

		lbAmount.text = [formatter stringFromNumber:tmpProject.totalForTable];
	}
	
	return cell;
}

/*
 *	Transitions to Formula view for detail display/editing
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Go to formula
	Project *tmp = [projects objectAtIndex:indexPath.row];
	if( tmp ) {
		ProjectViewController *pvc = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
		pvc.project = tmp;
		[self.navigationController pushViewController:pvc animated:YES];
		[pvc release];
	}
}

/*
 *	Allows for the delete button when swiping a cell
 */
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}



@end
