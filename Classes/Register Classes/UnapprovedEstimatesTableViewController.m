//
//  UnapprovedEstimatesTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 4/9/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectEstimateInvoiceViewController.h"
#import "ProjectInvoice.h"
#import "UnapprovedEstimatesTableViewController.h"


@implementation UnapprovedEstimatesTableViewController

@synthesize estimateCell, tblEstimates;

- (void) viewDidLoad {
	self.title = @"Unapproved Estimates";
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulateEstimates];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[estimates release];
	[formatter release];
	self.tblEstimates = nil;
    [super dealloc];
}

- (void) releaseAndRepopulateEstimates {
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	if( estimates )	[estimates release];	
	[[PSADataManager sharedInstance] getArrayOfUnpaidInvoicesByType:iBizProjectEstimate];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	estimates = [theArray retain];
	// Reload and resume normal activity
	[tblEstimates reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}


#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( estimates )	return estimates.count;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UnapprovedEstimateCell"];
	if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"UnapprovedEstimateCell" owner:self options:nil];
		cell = estimateCell;
		self.estimateCell = nil;
	}
	
	ProjectInvoice *tmp = [estimates objectAtIndex:indexPath.row];
	if( tmp ) {
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
		UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
		
		lbName.text = tmp.name;
		
		if( tmp.dateDue ) {
			NSString *detail = [[NSString alloc] initWithFormat:@"Due: %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateDue withFormat:NSDateFormatterLongStyle]];
			lbStatusTime.text = detail;
			[detail release];
		} else {
			NSString *detail = [[NSString alloc] initWithFormat:@"Created: %@", [[PSADataManager sharedInstance] getStringForDate:tmp.dateOpened withFormat:NSDateFormatterLongStyle]];
			lbStatusTime.text = detail;
			[detail release];
		}
		
		lbAmount.text = [formatter stringFromNumber:tmp.totalForTable];
		
		if( [[NSDate date] timeIntervalSinceDate:tmp.dateDue] > 0 ) {
			lbAmount.textColor = [UIColor redColor];
		} else {
			lbAmount.textColor = [UIColor blackColor];
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	ProjectInvoice *tmp = [estimates objectAtIndex:indexPath.row];
	if( tmp ) {
		Project *project = [[PSADataManager sharedInstance] getProjectWithID:tmp.projectID];
		[project hydrate];
		for( ProjectInvoice *invoice in [project.payments objectForKey:[project getKeyForEstimates]] ) {
			if( invoice.invoiceID == tmp.invoiceID ) {
				ProjectEstimateInvoiceViewController *cont = [[ProjectEstimateInvoiceViewController alloc] initWithNibName:@"ProjectEstimateInvoiceView" bundle:nil];
				cont.invoice = invoice;
				cont.project = project;
				cont.isModal = NO;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			}
		}
		[project release];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

@end
