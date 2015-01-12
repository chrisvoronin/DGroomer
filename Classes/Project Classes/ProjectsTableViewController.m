//
//  ProjectsTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/17/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "PSADataManager.h"
#import "Project.h"
#import "ProjectEditViewController.h"
#import "ProjectViewController.h"
#import "ProjectsTableViewController.h"


@implementation ProjectsTableViewController

@synthesize dontAllowNewProject, projectsDelegate, projectsTableCell, segProjectType, tblProjects;


- (void) viewDidLoad {
	self.title = @"Projects";
	// Set default delegate
	if( !projectsDelegate )	projectsDelegate = self;
	if( !dontAllowNewProject ) {
		// Add "+" Button
		UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProject)];
		self.navigationItem.rightBarButtonItem = btnAdd;
		[btnAdd release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulateProjects];
}


- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	[projects release];
	[sortedKeys release];
	[filteredList release];
	self.segProjectType = nil;
	self.tblProjects = nil;
    [super dealloc];
}


- (void) releaseAndRepopulateProjects {
	[self.segProjectType setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	if( projects ) {
		//for( NSArray *tmp in [projects allValues] ) {
		//	[tmp makeObjectsPerformSelector:@selector(dehydrate)];
		//}
		[projects release];
	}
	[[PSADataManager sharedInstance] getArrayOfProjectsByType:segProjectType.selectedSegmentIndex];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	projects = [[PSADataManager sharedInstance] getDictionaryOfProjectsFromArray:theArray];
	// Sort by date DESC
	[self setSortedKeys];	
	// Create a search bar list of all the client objects
	if( filteredList )	[filteredList release];
	filteredList = [[NSMutableArray alloc] init];
	// Reload and resume normal activity
	[tblProjects reloadData];
	[self.searchDisplayController.searchResultsTableView reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segProjectType setUserInteractionEnabled:YES];
}

- (void) setSortedKeys {
	// Temporary array of keys sorted by date string ascending
	NSArray	*tmpArray = [[[projects allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
	// Storage for reversal
	NSMutableArray *reverseValues = [[NSMutableArray alloc] init];
	// Go through the tmp and add to the reversed array last->first
	for( int i = tmpArray.count-1; i >= 0; i-- ) {
		[reverseValues addObject:[tmpArray objectAtIndex:i]];
	}
	[tmpArray release];
	// Set the keys
	if( sortedKeys ) [sortedKeys release];
	sortedKeys = reverseValues;
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -
- (void) addProject {
	ProjectEditViewController *pvc = [[ProjectEditViewController alloc] initWithNibName:@"ProjectEditView" bundle:nil];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	pvc.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[pvc release];
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

- (IBAction) segProjectTypeChanged:(id)sender {
	[self releaseAndRepopulateProjects];
}

#pragma mark -
#pragma mark myBusiness Delegate Methods
#pragma mark -
- (void) selectionMadeWithProject:(Project*)theProject {
	ProjectViewController *pvc = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
	pvc.project = theProject;
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if( tv == self.searchDisplayController.searchResultsTableView )	return 1;
	// One for each group
	return [sortedKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return nil;
	//
	NSDate *tmp = [sortedKeys objectAtIndex:section];
	if( tmp ) {
		return [[PSADataManager sharedInstance] getStringForDate:tmp withFormat:NSDateFormatterLongStyle];
	}
	return @"";
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( aTableView == self.searchDisplayController.searchResultsTableView )	return filteredList.count;
	// Number of products for each group
	return [[projects objectForKey:[sortedKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ProjectsTableCell"];
	if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"ProjectsTableCell" owner:self options:nil];
		cell = projectsTableCell;
		self.projectsTableCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusClient = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	Project *tmpProject;
	if( aTableView == self.searchDisplayController.searchResultsTableView ) {
		tmpProject = [filteredList objectAtIndex:indexPath.row];
	} else {
		tmpProject = [[projects objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	}
	lbName.text = tmpProject.name;
	
	if( segProjectType.selectedSegmentIndex == 0 || segProjectType.selectedSegmentIndex == 3 ) {
		NSString *status = @"OPEN";
		if( tmpProject.dateCompleted != nil ) {
			status = @"COMPLETE";
		}
		NSString *detailText = [[NSString alloc] initWithFormat:@"%@ - %@", status, [tmpProject.client getClientName]];
		lbStatusClient.text = detailText;
		[detailText release];
	} else if( segProjectType.selectedSegmentIndex == 1 ) {
		NSString *due = nil;
		if( tmpProject.dateDue ) {
			due = [[NSString alloc] initWithFormat:@", Due %@", [[PSADataManager sharedInstance] getStringForDate:tmpProject.dateDue withFormat:NSDateFormatterShortStyle]];
		} else {
			due = [[NSString alloc] initWithString:@""];
		}
		NSString *detailText = [[NSString alloc] initWithFormat:@"%@%@", [tmpProject.client getClientName], due];
		[due release];
		lbStatusClient.text = detailText;
		[detailText release];
	} else {
		NSString *detailText = [[NSString alloc] initWithFormat:@"%@", [tmpProject.client getClientName]];
		lbStatusClient.text = detailText;
		[detailText release];
	}

	lbAmount.text = [formatter stringFromNumber:tmpProject.totalForTable];

	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( tableView == self.searchDisplayController.searchResultsTableView )	{
		[self.projectsDelegate selectionMadeWithProject:[filteredList objectAtIndex:indexPath.row]];
	} else {
		[self.projectsDelegate selectionMadeWithProject:[[projects objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

/*
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		projectToDelete = [indexPath retain];
		tableDeleting = tv;
        // Display alert
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Delete Project?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
    }
}*/


#pragma mark -
#pragma mark Content Filtering
#pragma mark -

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// First clear the filtered array.
	[filteredList removeAllObjects]; 
	// Add matching Products
	for( NSArray* arr in [projects allValues] ) {
		if( (NSNull*)arr != [NSNull null] ) {
			for( Project* prod in arr ) {
				if( [[prod.name lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 ) {
					[filteredList addObject:prod];
				}
			}
		}
	}
	
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
#pragma mark -

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
