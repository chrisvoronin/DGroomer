//
//  ProjectEstimateInvoicePickerViewController.m
//  myBusiness
//
//  Created by David J. Maier on 4/11/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Project.h"
#import "ProjectInvoice.h"
#import "ProjectInvoiceItem.h"
#import "ProjectProduct.h"
#import "ProjectService.h"
#import "PSADataManager.h"
#import "ProjectEstimateInvoicePickerViewController.h"


@implementation ProjectEstimateInvoicePickerViewController


@synthesize cellInvoice, project, product, service, tblInvoices;

- (void) viewDidLoad {
	//
	self.title = @"Add To";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblInvoices setBackgroundColor:bgColor];
	[bgColor release];
	// Add "+" Button
	UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnAdd;
	[btnAdd release];
	//
	selectionsEstimates = [[NSMutableArray alloc] init];
	selectionsInvoices = [[NSMutableArray alloc] init];
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	//
	[tblInvoices reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	self.tblInvoices = nil;
	[project release];
	[product release];
	[selectionsEstimates release];
	[selectionsInvoices release];
	[service release];
    [super dealloc];
}

- (void) done {
	// Create Invoice Item
	ProjectInvoiceItem *tmp = [[ProjectInvoiceItem alloc] init];
	if( product ) {
		tmp.item = product;
		tmp.itemID = product.productID;
	} else if( service ) {
		tmp.item = service;
		tmp.itemID = service.serviceID;
	}
	
	// For the selected...
	for( ProjectInvoice *inv in selectionsEstimates ) {
		tmp.invoiceID = inv.invoiceID;
		if( product ) {
			[inv.products addObject:tmp];
		} else {
			[inv.services addObject:tmp];
		}
		[[PSADataManager sharedInstance] saveInvoice:inv];
	}
	for( ProjectInvoice *inv in selectionsInvoices ) {
		tmp.invoiceID = inv.invoiceID;
		if( product ) {
			[inv.products addObject:tmp];
		} else {
			[inv.services addObject:tmp];
		}
		[[PSADataManager sharedInstance] saveInvoice:inv];
	}
	[tmp release];
	//
	[[PSADataManager sharedInstance] updateProjectTotal:project];
	// Should always be modal...
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	NSArray *tmp = nil;
	if( section == 0 ) {
		tmp = [project.payments objectForKey:[project getKeyForEstimates]];
	} else if( section == 1 ) {
		tmp = [project.payments objectForKey:[project getKeyForInvoices]];
	}
	return tmp.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ( section ) {
		case 0:		return [project getKeyForEstimates];
		case 1:		return [project getKeyForInvoices];
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ProjectInvoicePickerCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		cell = cellInvoice;
		self.cellInvoice = nil;
	}
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel	*lbTotal = (UILabel*)[cell viewWithTag:98];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	ProjectInvoice *tmp;
	if(	indexPath.section == 0 ) {
		tmp = [[project.payments objectForKey:[project getKeyForEstimates]] objectAtIndex:indexPath.row];
		if( [selectionsEstimates containsObject:tmp] ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	} else {
		tmp = [[project.payments objectForKey:[project getKeyForInvoices]] objectAtIndex:indexPath.row];
		if( [selectionsInvoices containsObject:tmp] ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	if( tmp ) {
		lbName.text = tmp.name;
		lbTotal.text = [formatter stringFromNumber:tmp.totalForTable];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( indexPath.section == 0 ) {
		ProjectInvoice *tmp = [[project.payments objectForKey:[project getKeyForEstimates]] objectAtIndex:indexPath.row];
		if( ![selectionsEstimates containsObject:tmp] ) {
			[selectionsEstimates addObject:tmp];
		} else {
			[selectionsEstimates removeObject:tmp];
		}
	} else {
		ProjectInvoice *tmp = [[project.payments objectForKey:[project getKeyForInvoices]] objectAtIndex:indexPath.row];
		if( ![selectionsInvoices containsObject:tmp] ) {
			[selectionsInvoices addObject:tmp];
		} else {
			[selectionsInvoices removeObject:tmp];
		}
	}
	[tblInvoices reloadData];
}


@end
