//
//  ProjectProductsViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductAdjustment.h"
#import "Project.h"
#import "ProjectProduct.h"
#import "ProjectProductDetailViewController.h"
#import "PSADataManager.h"
#import "ProjectProductsViewController.h"

@implementation ProjectProductsViewController

@synthesize cellProduct, project, tblProducts;

- (void) viewDidLoad {
	//
	self.title = @"Products";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblProducts setBackgroundColor:bgColor];
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
	[tblProducts reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	self.tblProducts = nil;
	[project release];
    [super dealloc];
}

- (void) add {
	// Show the product table in modal
	ProductsTableViewController *cont = [[ProductsTableViewController alloc] initWithNibName:@"ProductsTableView" bundle:nil];
	cont.productDelegate = self;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

- (void) deleteProduct {
	if( toDelete ) {
		[[PSADataManager sharedInstance] removeProjectProduct:toDelete fromProject:project];
		[project.products removeObject:toDelete];
		toDelete = nil;
		// Update Invoice & Project totals
		[[PSADataManager sharedInstance] updateAllInvoicesAndProject:project];
		[tblProducts reloadData];
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
		[self deleteProduct];
	} else {
		toDelete = nil;
	}
}


- (void) selectionMadeWithProduct:(Product*)theProduct {
	// See if this product already is in our project
	BOOL duplicate = NO;
	for( ProjectProduct *pp in project.products ) {
		if( pp.productID == theProduct.productID ) {
			duplicate = YES;
		}
	}
	
	if( duplicate ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Product" message:@"This product already exists in your project!\n\nPlease alter the quantity by tapping on the product on the table, instead of adding it multiple times." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];	
		[alert release];
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		// Create ProjectProduct with data of passed in Product
		ProjectProduct *tmp = [[ProjectProduct alloc] initWithProduct:theProduct];
		tmp.projectID = project.projectID;
		tmp.taxed = theProduct.productTaxable;
		tmp.cost = theProduct.productCost;
		tmp.price = theProduct.productPrice;
		// Show the detail view... curl animation
		[self.presentedViewController.view setUserInteractionEnabled:NO];
		// Create the detail view
		ProjectProductDetailViewController *cont = [[ProjectProductDetailViewController alloc] initWithNibName:@"ProjectProductDetailView" bundle:nil];
		cont.isModal = YES;
		cont.project = project;
		cont.projectProduct = tmp;
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
	
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( section == 0 )	return project.products.count;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"ProjectProductCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		cell = cellProduct;
		self.cellProduct = nil;
	}

	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel	*lbQty = (UILabel*)[cell viewWithTag:98];
	UILabel	*lbTotal = (UILabel*)[cell viewWithTag:97];
	UILabel	*lbTitleQty = (UILabel*)[cell viewWithTag:96];
	
	if( indexPath.section == 1 ) {
		if( project.products.count == 0 ) {
			lbName.text = @"No Products";
			lbQty.text = @"";
			lbTitleQty.hidden = YES;
			lbTotal.text = @"";
		} else {
			NSArray *totals = [project getProductTotals];
			lbName.text = @"Total";
			lbTitleQty.hidden = NO;
			lbQty.text = [(NSNumber*)[totals objectAtIndex:0] stringValue];
			lbTotal.text = [formatter stringFromNumber:[totals objectAtIndex:1]];
		}
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if( indexPath.section == 0 ) {
		lbTitleQty.hidden = NO;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//
		ProjectProduct *tmpProduct = [project.products objectAtIndex:indexPath.row];
		//
		if( tmpProduct ) {
			lbName.text = tmpProduct.productName;
			NSString *qty = [[NSString alloc] initWithFormat:@"%d", tmpProduct.productAdjustment.quantity];
			lbQty.text = qty;
			[qty release];
			lbTotal.text = [formatter stringFromNumber:[NSNumber numberWithDouble:([[tmpProduct getSubTotal] doubleValue]-[[tmpProduct getDiscountAmount] doubleValue])]];
		}
	}
	
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section == 0 )	return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	toDelete = [project.products objectAtIndex:indexPath.row];
	if( [[project.payments objectForKey:[project getKeyForEstimates]] count] > 0 || [[project.payments objectForKey:[project getKeyForInvoices]] count] > 0 ) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"This will also remove the product from any estimates and invoices!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[sheet showInView:self.view];
		[sheet release];
	} else {
		[self deleteProduct];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( indexPath.section == 0 ) {
		ProjectProduct *tmp = [project.products objectAtIndex:indexPath.row];
		if( tmp ) {
			ProjectProductDetailViewController *cont = [[ProjectProductDetailViewController alloc] initWithNibName:@"ProjectProductDetailView" bundle:nil];
			cont.isModal = NO;
			cont.project = project;
			cont.projectProduct = tmp;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
		}
	}
}


@end
