//
//  ProjectServicesViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectService.h"
#import "ProjectServicePriceDetailViewController.h"
#import "ProjectServiceTimerViewController.h"
#import "ProjectServicesViewController.h"


@implementation ProjectServicesViewController

@synthesize cellService, project, tblServices;

- (void) viewDidLoad {
	//
	self.title = @"Services";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblServices setBackgroundColor:bgColor];
	[bgColor release];
	// Add "+" Button
	if( !project.dateCompleted ) {
		UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
		self.navigationItem.rightBarButtonItem = btnAdd;
		[btnAdd release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {

	[tblServices reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.tblServices = nil;
	[formatter release];
	[project release];
    [super dealloc];
}

- (void) add {
	// Show the product table in modal
	ServicesTableViewController *cont = [[ServicesTableViewController alloc] initWithNibName:@"ServicesTableView" bundle:nil];
	cont.serviceDelegate = self;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (void) deleteService {
	if( toDelete ) {
		[[PSADataManager sharedInstance] removeProjectService:toDelete fromProject:project];
		[project.services removeObject:toDelete];
		toDelete = nil;
		// Update Invoice & Project totals
		[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
		[tblServices reloadData];
	}
}

- (IBAction) goToTimer:(id)sender {
	UITableViewCell *tvc = (UITableViewCell*)[[sender superview] superview];
	NSIndexPath *ip = [tblServices indexPathForCell:tvc];
	if( ip ) {
		ProjectService *ps = [project.services objectAtIndex:ip.row];
		if( ps ) {
			ProjectServiceTimerViewController *cont = [[ProjectServiceTimerViewController alloc] initWithNibName:@"ProjectServiceTimerView" bundle:nil];
			cont.project = project;
			cont.projectService = ps;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}

#pragma mark -
#pragma mark Other Delegate Methods
#pragma mark -
/*
 *	
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 0 ) {
		[self deleteService];
	} else {
		toDelete = nil;
	}
}

- (void) selectionMadeWithService:(Service*)theService {
	// Create ProjectService with data of passed in Service
	ProjectService *tmp = [[ProjectService alloc] initWithService:theService];
	tmp.projectID = project.projectID;
	tmp.taxed = theService.taxable;
	tmp.cost = theService.serviceCost;
	tmp.price = theService.servicePrice;
	tmp.setupFee = theService.serviceSetupFee;
	tmp.isFlatRate = theService.serviceIsFlatRate;
	// Show the detail view... curl animation
	[self.presentedViewController.view setUserInteractionEnabled:NO];
	// Create the detail view
	ProjectServicePriceDetailViewController *cont = [[ProjectServicePriceDetailViewController alloc] initWithNibName:@"ProjectServicePriceDetailView" bundle:nil];
	cont.isModal = YES;
	cont.project = project;
	cont.projectService = tmp;
	[tmp release];
	// Animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.presentedViewController.view cache:YES];
	NSArray *controllers = [NSArray arrayWithObject:cont];
	if( [self.presentedViewController isKindOfClass:[UINavigationController class]] ) {
		[(UINavigationController*)self.presentedViewController setViewControllers:controllers animated:NO];
	}
	[UIView commitAnimations];
	// Resume
	[self.presentedViewController.view setUserInteractionEnabled:YES];
	[cont release];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return project.services.count;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ProjectServiceCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"ProjectServiceCell" owner:self options:nil];
		cell = cellService;
		self.cellService = nil;
	}
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
	UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
	UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
	UIButton *btnTimer = (UIButton*)[cell viewWithTag:95];
	
	if( indexPath.section == 1 ) {
		if( project.services.count == 0 ) {
			lbName.text = @"No Services";
			lbTotal.text = @"";
			lbQty.text = @"";
			lbTitleQty.hidden = YES;
		} else {
			NSArray *totals = [project getServiceTotals];
			lbName.text = @"Total";
			lbTitleQty.hidden = NO;
			lbQty.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:[(NSNumber*)[totals objectAtIndex:0] integerValue]];
			lbTotal.text = [formatter stringFromNumber:[totals objectAtIndex:1]];
		}
		btnTimer.hidden = YES;
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if( indexPath.section == 0 ) {
		lbTitleQty.hidden = NO;
		//
		ProjectService *tmpService = [project.services objectAtIndex:indexPath.row];
		//
		if( tmpService ) {
			lbName.text = tmpService.serviceName;
			if( tmpService.isFlatRate ) {
				lbQty.text = @"Flat";
				btnTimer.hidden = YES;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			} else {
				btnTimer.hidden = NO;
				cell.accessoryType = UITableViewCellAccessoryNone;
				if( tmpService.isTimed ) {
					if( tmpService.isTiming ) {
						lbQty.text = @"Timing";
						[btnTimer setImage:[UIImage imageNamed:@"btnServiceTimerOn.png"] forState:UIControlStateNormal];
					} else {
						lbQty.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:tmpService.secondsWorked];
						[btnTimer setImage:[UIImage imageNamed:@"btnServiceTimerOff.png"] forState:UIControlStateNormal];
					}
				} else {
					lbQty.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:tmpService.secondsWorked];
					[btnTimer setImage:[UIImage imageNamed:@"btnServiceTimer.png"] forState:UIControlStateNormal];
				}
			}
			lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithDouble:([[tmpService getSubTotal] doubleValue]-[[tmpService getDiscountAmount] doubleValue])]];
		}
	}
	
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 0 )	return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	toDelete = [project.services objectAtIndex:indexPath.row];
	if( [[project.payments objectForKey:[project getKeyForEstimates]] count] > 0 || [[project.payments objectForKey:[project getKeyForInvoices]] count] > 0 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"This will also remove the service from any estimates and invoices!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
	} else {
		[self deleteService];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( indexPath.section == 0 ) {
		ProjectService *tmp = [project.services objectAtIndex:indexPath.row];
		if( tmp ) {
			ProjectServicePriceDetailViewController *cont = [[ProjectServicePriceDetailViewController alloc] initWithNibName:@"ProjectServicePriceDetailView" bundle:nil];
			cont.isModal = NO;
			cont.project = project;
			cont.projectService = tmp;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}


@end
