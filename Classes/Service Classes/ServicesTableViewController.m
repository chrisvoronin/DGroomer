//
//  ServiceViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "Service.h"
#import "ServiceInformationController.h"
#import "ServicesTableViewController.h"


@implementation ServicesTableViewController

@synthesize myTableView, serviceDelegate, segActive;


- (void)viewDidLoad {
	self.title = @"Services";
	//
	if( !serviceDelegate ) {
		serviceDelegate = self;
	}
	serviceToDelete = nil;
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addService)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulateServices];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[formatter release];
	[services release];
	[sortedKeys release];
	[filteredList release];
	self.segActive = nil;
	self.myTableView = nil;
    [super dealloc];
}

- (void) addService {
	// Load the Service Detail NIB file
	ServiceInformationController *cont = [[ServiceInformationController alloc] initWithNibName:@"ServiceInformation" bundle:nil];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelService)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (void) cancelService{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) releaseAndRepopulateServices {
	[self.segActive setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getDictionaryOfServicesByGroupWithActiveFlag:(segActive.selectedSegmentIndex == 0) ? YES : NO];
}


- (void) dataManagerReturnedDictionary:(NSDictionary*)theDictionary {
	// Get dictionary from array...
	if( services )		[services release];
	services = [theDictionary retain];
	// Make the groups sorted
	if( sortedKeys )	[sortedKeys release];
	sortedKeys = [[[services allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
	// Create a search bar list of all the client objects
	if( filteredList )	[filteredList release];
	filteredList = [[NSMutableArray alloc] init];
	// Reload and resume operation
	[myTableView reloadData];
	[self.searchDisplayController.searchResultsTableView reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segActive setUserInteractionEnabled:YES];
}


/*
 *	segActiveValueChanged:
 *	Fetches the proper product list and reloads the table
 */
- (IBAction) segActiveValueChanged:(id)sender {
	[self releaseAndRepopulateServices];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -
/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Clicked the Delete button
	if( buttonIndex == 0 ) {
		if( serviceToDelete != nil ) {

			// Get the Product we're deleting
			Service *tmpService;
			if( tableDeleting == self.searchDisplayController.searchResultsTableView ) {
				tmpService = [filteredList objectAtIndex:serviceToDelete.row];
			} else {
				tmpService = [[services objectForKey:[sortedKeys objectAtIndex:serviceToDelete.section]] objectAtIndex:serviceToDelete.row];
			}
			if( tmpService ){
				[[PSADataManager sharedInstance] removeService:tmpService];
			}
			// Release and repopulate our dictionary
			// Also reloads the table so no need to manually delete rows
			[self releaseAndRepopulateServices];
			/*
			// Delete the entire section if there is only 1 row in it
			if( [myTableView numberOfRowsInSection:serviceToDelete.section] == 1 ) {
				NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:serviceToDelete.section];
				[myTableView deleteSections:set withRowAnimation:UITableViewRowAnimationTop];
				[set release];
			} else {
				[myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:serviceToDelete] withRowAnimation:UITableViewRowAnimationTop];
			}*/
		}		
	}
	tableDeleting = nil;
	[serviceToDelete release];
	serviceToDelete = nil;
}

#pragma mark -
#pragma mark PSAServiceTableDelegate Methods
#pragma mark -
/*
 *	When this class is responding to it's own delegate, go to the Service view.
 */
- (void) selectionMadeWithService:(Service*)theService {
	// Go to Service Detail View
	ServiceInformationController *tmp = [[ServiceInformationController alloc] initWithNibName:@"ServiceInformation" bundle:nil];
	tmp.service = theService;
	[self.navigationController pushViewController:tmp animated:YES];
	[tmp release];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if( tv == self.searchDisplayController.searchResultsTableView )	return 1;
	return [sortedKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return nil;
	return [sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( aTableView == self.searchDisplayController.searchResultsTableView )	return filteredList.count;
	return [[services objectForKey:[sortedKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ServiceCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		// If this goes to the Service edit view, show the indicator
		if( serviceDelegate == self ) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		// Set up a view to show the Service's color on the edge of the cell
		UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 44)];
		colorView.opaque = YES;
		colorView.tag = 88;
		[cell.contentView addSubview:colorView];
		[colorView release];
    }
	
	Service *tmp;
	if( aTableView == self.searchDisplayController.searchResultsTableView ) {
		tmp = [filteredList objectAtIndex:indexPath.row];
	} else {
		tmp = [[services objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.text = tmp.serviceName;
	[cell.contentView viewWithTag:88].backgroundColor = tmp.color;
	
	NSInteger numberOfSeconds = tmp.duration;
	NSString *detailText = [[NSString alloc] initWithFormat:@"%@Price: %@%@  Duration: %@", (tmp.isActive) ? @"" : @"INACTIVE  ", [formatter stringFromNumber:tmp.servicePrice], (tmp.serviceIsFlatRate) ? @"" : @"/hr.", [[PSADataManager sharedInstance] getStringOfHoursAndMinutesForSeconds:numberOfSeconds]];
	cell.detailTextLabel.text = detailText;
	[detailText release];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// Call the delegate method
	if( tableView == self.searchDisplayController.searchResultsTableView )	{
		[serviceDelegate selectionMadeWithService:[filteredList objectAtIndex:indexPath.row]];
	} else {
		[serviceDelegate selectionMadeWithService:[[services objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
	}
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		serviceToDelete = [indexPath retain];
		tableDeleting = tv;
        // Display alert
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This will make the Service inactive." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
    }
}

#pragma mark -
#pragma mark Content Filtering
#pragma mark -

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// First clear the filtered array.
	[filteredList removeAllObjects]; 
	// Add matching Products
	for( NSArray* arr in [services allValues] ) {
		if( (NSNull*)arr != [NSNull null] ) {
			for( Service* serv in arr ) {
				if( [[serv.serviceName lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 ) {
					[filteredList addObject:serv];
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

