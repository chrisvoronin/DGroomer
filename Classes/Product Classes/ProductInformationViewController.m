//
//  ProductsInformationController.m
//  myBusiness
//
//  Created by David J. Maier on 7/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Product.h"
#import "ProductAmountViewController.h"
#import "ProductInventoryViewController.h"
#import "ProductNameViewController.h"
#import "ProductPriceViewController.h"
#import "ProductType.h"
#import "PSADataManager.h"
#import "Vendor.h"
#import "ProductInformationViewController.h"
#import "ProductStockTableViewCell.h"

@implementation ProductInformationViewController

@synthesize myTableView, product;


- (void)viewDidLoad {
    if(self.title.length<1)
        self.title = @"ADD PRODUCT";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundRed.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[myTableView setBackgroundColor:bgColor];
	[bgColor release];*/
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	// Save Button
	UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = btnSave;
	[btnSave release];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;

	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) setTitleName:(NSString*)strName{
    self.title = strName;
}
- (void)viewWillAppear:(BOOL)animated {
	if( product == nil )	product = [[Product alloc] init];
	[myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[formatter release];
	self.myTableView = nil;
	[product release];
    [super dealloc];
}


- (void) save {
	if( product.productTypeID > -1 ) {
		[[PSADataManager sharedInstance] saveProduct:product];
		if( self.navigationController.viewControllers.count == 1 ) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Product" message:@"Please select a Product Type before saving." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

- (void) cancelEdit{
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Custom Delegate Methods
#pragma mark -
/*
 *
 */
- (void) selectionMadeWithProductType:(ProductType*)theType {
	// Save the values
	product.productTypeID = theType.typeID;
	product.productTypeName = theType.typeDescription;
	// Remove the type table view
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 *
 *
 */
- (void) selectionMadeWithVendor:(Vendor*)theVendor {
	product.productVendorName = theVendor.vendorName;
	product.vendorID = theVendor.vendorID;
	// Remove the vendor table view
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return 5;
	else if( section == 1 )	return 3;
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"ProductCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ProductCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch ( indexPath.section ) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Product Type";
					cell.detailTextLabel.text = product.productTypeName;
					break;
				case 1:
					cell.textLabel.text = @"Name";
					cell.detailTextLabel.text = product.productName;
					break;
				case 2:
					cell.textLabel.text = @"Identifier";
					if( product.productNumber ) {
						cell.detailTextLabel.text = product.productNumber;
					}
					break;
				case 3:
					cell.textLabel.text = @"Vendor";
					if( [product.productVendorName isEqualToString:@"(null)"] || [product.productVendorName isEqualToString:@""] ) {
						cell.detailTextLabel.text = @"No Name";
					} else {
						cell.detailTextLabel.text = product.productVendorName;
					}
					break;
				case 4:
					cell.textLabel.text = @"Active";
					cell.detailTextLabel.text = (product.isActive) ? @"Yes" : @"No";
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Cost";
					cell.detailTextLabel.text = [formatter stringFromNumber:product.productCost];
					break;
				case 1:
					cell.textLabel.text = @"Price";			
					cell.detailTextLabel.text = [formatter stringFromNumber:product.productPrice];
					break;
				case 2:
					cell.textLabel.text = @"Taxable";
					if( product.productTaxable ) {
						cell.detailTextLabel.text = @"Yes";
					} else {
						cell.detailTextLabel.text = @"No";
					}
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.textLabel.text = @"In Stock";
					NSString *stock = [[NSString alloc] initWithFormat:@"%ld", (long)product.productInStock];
					cell.detailTextLabel.text = stock;
					[stock release];
					break;
				case 1:
					cell.textLabel.text = @"Min. Inventory";
					NSString *min = [[NSString alloc] initWithFormat:@"%ld", (long)product.productMin];
					cell.detailTextLabel.text = min;
					[min release];
					break;
				case 2:
					cell.textLabel.text = @"Max. Inventory";
					NSString *max = [[NSString alloc] initWithFormat:@"%ld", (long)product.productMax];
					cell.detailTextLabel.text = max;
					[max release];
					break;
			}
			break;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	switch ( indexPath.section ) {
		case 0:
			switch (indexPath.row) {
				case 0: {
					ProductTypeTableViewController *cont = [[ProductTypeTableViewController alloc] initWithNibName:@"ProductTypeTableView" bundle:nil];
					cont.typeDelegate = self;
					[self.navigationController pushViewController:cont animated:YES];
					[cont release];
					break;
				}
				case 3: {
					VendorTableViewController *vend = [[VendorTableViewController alloc] initWithNibName:@"VendorTableView" bundle:nil];
					vend.delegate = self;
					[self.navigationController pushViewController:vend animated:YES];
					[vend release];
					break;
				}
				default: {
					ProductNameViewController *name = [[ProductNameViewController alloc] initWithNibName:@"ProductNameView" bundle:nil];
					name.product = product;
					[self.navigationController pushViewController:name animated:YES];
					[name release];
					break;
				}
			}
			break;
		case 1: {
			ProductPriceViewController *price = [[ProductPriceViewController alloc] initWithNibName:@"ProductPriceView" bundle:nil];
			price.product = product;
			[self.navigationController pushViewController:price animated:YES];
			[price release];
			break;
		}
		case 2: {
			if( indexPath.row != 0 ) {
				ProductAmountViewController *amt = [[ProductAmountViewController alloc] initWithNibName:@"ProductAmountView" bundle:nil];
				amt.product = product;
				[self.navigationController pushViewController:amt animated:YES];
				[amt release];
				break;
            } else {
                ProductInventoryViewController *cont = [[ProductInventoryViewController alloc] initWithNibName:@"ProductInventoryView" bundle:nil];
                cont.product = product;
                [self.navigationController pushViewController:cont animated:YES];
                [cont release];
            }
		}
	}	
}

/*- (UIView *)createAccessoryView {
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *disclosureButton = [UIButton buttonWithType:UITableViewCellAccessoryDetailDisclosureButton];
    
    disclosureButton.tag = 100;
    [disclosureButton addTarget:self action:@selector(pressedAccessory:) forControlEvents:UIControlEventTouchUpInside];
    CGRect r = disclosureButton.frame;
    r.origin.x -= 80;
    disclosureButton.frame = r;
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.tag = 101;
    aiv.alpha = 0.0;
    aiv.center = disclosureButton.center;
    
    accessoryView.bounds = disclosureButton.bounds;
    [accessoryView addSubview:aiv];
    [accessoryView addSubview:disclosureButton];
    return accessoryView;
}

- (void)pressedAccessory:(UIButton *)sender {
    
    
}*/

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"This gives you the ability to add inventory, record it if you use it in the store or record it if you forgot to add it to a transaction."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
