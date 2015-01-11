//
//  ProductInventoryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/30/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import "ProductAdjustment.h"
#import "ProductInventoryQuantityViewController.h"
#import "PSADataManager.h"
#import "ProductInventoryViewController.h"


@implementation ProductInventoryViewController

@synthesize adjustment, product, tblInventory;

- (void)viewDidLoad {
	self.title = @"Inventory";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblInventory setBackgroundColor:bgColor];
	[bgColor release];
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
	//
	adjustmentValues = [[NSArray alloc] initWithObjects:@"Added To Inventory", @"Used Professionally", @"Sold As Retail", nil];
	//
    [super viewDidLoad];
    
    if( !adjustment ) {
		adjustment = [[ProductAdjustment alloc] init];
		adjustment.productID = product.productID;
		adjustment.type = PSAProductAdjustmentAdd;
	}
    
    if(product){
        adjustment.quantity = product.productInStock;
    }
}

- (void) viewWillAppear:(BOOL)animated {
	[tblInventory reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[adjustmentValues release];
	[adjustment release];
	[product release];
	self.tblInventory = nil;
    [super dealloc];
}

- (void) save {
	if( adjustment ) {
		if( product.productID == -1 ) {
			// Store this until our product has a valid ID
			[product addAdjustmentForFuture:adjustment];
		} else {
			// Save now
			[[PSADataManager sharedInstance] insertProductAdjustment:adjustment];
		}
		// Update the product's stock variable
		if( adjustment.type == PSAProductAdjustmentAdd ) {
			product.productInStock = product.productInStock + adjustment.quantity;
		} else {
			product.productInStock = product.productInStock - adjustment.quantity;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -

- (void) selectionMadeWithString:(NSString*)theValue {
	for( NSInteger i=0; i < adjustmentValues.count; i++ ){
		if( [[adjustmentValues objectAtIndex:i] isEqualToString:theValue] ) {
			adjustment.type = i;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"InventoryCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"InventoryCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UIColor *tmp = cell.textLabel.textColor;
		cell.textLabel.textColor = cell.detailTextLabel.textColor;
		cell.detailTextLabel.textColor = tmp;
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
		
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    }
	
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Type";
				cell.detailTextLabel.text = [adjustmentValues objectAtIndex:adjustment.type];
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Quantity";
				NSString *str = [[NSString alloc] initWithFormat:@"%ld", (long)adjustment.quantity];
				cell.detailTextLabel.text = str;
				[str release];
			}
			break;
	}
	
	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// GoTo
	switch ( indexPath.row ) {
		case 0: {
			TablePickerViewController *picker = [[TablePickerViewController alloc] initWithNibName:@"TablePickerView" bundle:nil];
			picker.title = @"Adjustment Type";
			picker.pickerDelegate = self;
			picker.selectedValue = [adjustmentValues objectAtIndex:adjustment.type];
			picker.pickerValues = adjustmentValues;
			[self.navigationController pushViewController:picker animated:YES];
			// Set the background
			UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
			UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
			[picker.tblItems setBackgroundColor:bgColor];
			[bgColor release];
			//
			[picker release];
			break;
		}
		case 1: {
			ProductInventoryQuantityViewController *cont = [[ProductInventoryQuantityViewController alloc] initWithNibName:@"ProductInventoryQuantityView" bundle:nil];
			cont.adjustment = adjustment;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}


@end
