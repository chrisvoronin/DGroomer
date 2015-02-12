//
//  ProductViewController.m
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Company.h"
#import "Product.h"
#import "ProductInformationViewController.h"
#import "PSADataManager.h"
#import "ProductsTableViewController.h"


@implementation ProductsTableViewController

@synthesize isInventoryReport, myTableView, productDelegate, productInventoryCell, segActive;


- (void) viewDidLoad {
	if( productDelegate == nil ) {
		self.productDelegate = self;
	}
	productToDelete = nil;
	if( isInventoryReport ) {
		self.title = @"PRODUCT INVENTORY";
		// Email Button
		UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailReport)];
		self.navigationItem.rightBarButtonItem = btnEmail;
		[btnEmail release];
	} else {
		self.title = @"PRODUCTS";
		// Add "+" Button
		UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct)];
		self.navigationItem.rightBarButtonItem = btnAdd;
		[btnAdd release];
	}
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationController.view.tintColor};
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	[self releaseAndRepopulateProducts];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[formatter release];
	[products release];
	[sortedKeys release];
	[filteredList release];
	self.myTableView = nil;
	self.segActive = nil;
    [super dealloc];
}

- (void) cancelEdit{
    if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void) releaseAndRepopulateProducts {
	[self.segActive setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	if( products )		[products release];
	[[PSADataManager sharedInstance] getDictionaryOfProductsByTypeWithActiveFlag:(segActive.selectedSegmentIndex == 0) ? YES : NO];
}

- (void) dataManagerReturnedDictionary:(NSDictionary*)theDictionary {
	// Get dictionary from array...
	products = [theDictionary retain];
	// Make the types sorted
	if( sortedKeys )	[sortedKeys release];
	sortedKeys = [[[products allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
	// Create a search bar list of all the client objects
	if( filteredList )	[filteredList release];
	filteredList = [[NSMutableArray alloc] init];
	// Reload and resume normal activity
	[myTableView reloadData];
	[self.searchDisplayController.searchResultsTableView reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segActive setUserInteractionEnabled:YES];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (void) addProduct {
	ProductInformationViewController *cont = [[ProductInformationViewController alloc] initWithNibName:@"ProductInformation" bundle:nil];
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:cont action:@selector(cancelEdit)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	//nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

/*
 *	segActiveValueChanged:
 *	Fetches the proper product list and reloads the table
 */
- (IBAction) segActiveValueChanged:(id)sender {
	[self releaseAndRepopulateProducts];
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
		if( productToDelete != nil ) {
			// Get the Product we're deleting
			Product *tmpProduct;
			if( tableDeleting == self.searchDisplayController.searchResultsTableView ) {
				tmpProduct = [filteredList objectAtIndex:productToDelete.row];
			} else {
				tmpProduct = [[products objectForKey:[sortedKeys objectAtIndex:productToDelete.section]] objectAtIndex:productToDelete.row];
			}
			if( tmpProduct ){
				[[PSADataManager sharedInstance] removeProduct:tmpProduct];
			}
			// Release and repopulate our dictionary
			// Also reloads the table so no need to manually delete rows
			[self releaseAndRepopulateProducts];
			/*
			// Delete the entire section if there is only 1 row in it
			if( [myTableView numberOfRowsInSection:productToDelete.section] == 1 ) {
				NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:productToDelete.section];
				[myTableView deleteSections:set withRowAnimation:UITableViewRowAnimationTop];
				[set release];
			} else {
				[myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:productToDelete] withRowAnimation:UITableViewRowAnimationTop];
			}
			 */
		}		
	}
	tableDeleting = nil;
	[productToDelete release];
	productToDelete = nil;
}

#pragma mark -
#pragma mark PSAProductTableDelegate Methods
#pragma mark -
/*
 *	When this class is responding to it's own delegate, go to the Product view.
 */
- (void) selectionMadeWithProduct:(Product*)theProduct {
	ProductInformationViewController *tmp = [[ProductInformationViewController alloc] initWithNibName:@"ProductInformation" bundle:nil];
	tmp.product = theProduct;
    [tmp setTitleName:theProduct.productName];
	[self.navigationController pushViewController:tmp animated:YES];
	[tmp release];
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
	// Return the group name
	return [sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( aTableView == self.searchDisplayController.searchResultsTableView )	return filteredList.count;
	// Number of products for each group
	return [[products objectForKey:[sortedKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( isInventoryReport ) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ProductInventoryCell"];
		if (cell == nil) {
			// Load the NIB
			[[NSBundle mainBundle] loadNibNamed:@"ProductInventoryTableCell" owner:self options:nil];
			cell = productInventoryCell;
			self.productInventoryCell = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		
		Product *tmpProduct;
		if( aTableView == self.searchDisplayController.searchResultsTableView ) {
			tmpProduct = [filteredList objectAtIndex:indexPath.row];
		} else {
			tmpProduct = [[products objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		}
		
		UILabel *lbName = (UILabel*)[cell viewWithTag:99];
		UILabel *lbMin = (UILabel*)[cell viewWithTag:98];
		UILabel *lbCurrent = (UILabel*)[cell viewWithTag:97];
		UILabel *lbMax = (UILabel*)[cell viewWithTag:96];
		// Colorize
		if( tmpProduct.productMin > tmpProduct.productInStock ) {
			lbCurrent.textColor = [UIColor redColor];
		} else {
			lbCurrent.textColor = [UIColor blueColor];
		}
		// Set the strings!
		NSString *min = [[NSString alloc] initWithFormat:@"%d", tmpProduct.productMin];
		NSString *cur = [[NSString alloc] initWithFormat:@"%d", tmpProduct.productInStock];
		NSString *max = [[NSString alloc] initWithFormat:@"%d", tmpProduct.productMax];
		lbName.text = tmpProduct.productName;
		lbMax.text = max;
		lbMin.text = min;
		lbCurrent.text = cur;		
		[max release];
		[min release];
		[cur release];
		
		return cell;
	} else {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ProductCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProductCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			if( productDelegate == self ) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		
		Product *tmpProduct;
		if( aTableView == self.searchDisplayController.searchResultsTableView ) {
			tmpProduct = [filteredList objectAtIndex:indexPath.row];
		} else {
			tmpProduct = [[products objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		}
		cell.textLabel.text = tmpProduct.productName;

		NSString *detailText = [[NSString alloc] initWithFormat:@"%@%@Price: %@, In Stock: %d", (tmpProduct.isActive) ? @"" : @"INACTIVE  ", (tmpProduct.productNumber) ? [NSString stringWithFormat:@"id:%@, ", tmpProduct.productNumber] : @"", [formatter stringFromNumber:tmpProduct.productPrice], tmpProduct.productInStock];
		cell.detailTextLabel.text = detailText;
		[detailText release];
		
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	if( tableView == self.searchDisplayController.searchResultsTableView )	{
		[self.productDelegate selectionMadeWithProduct:[filteredList objectAtIndex:indexPath.row]];
	} else {
		[self.productDelegate selectionMadeWithProduct:[[products objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if( isInventoryReport )	return UITableViewCellEditingStyleNone;
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		productToDelete = [indexPath retain];
		tableDeleting = tv;
        // Display alert
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This will make the product inactive." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
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
	for( NSArray* arr in [products allValues] ) {
		if( (NSNull*)arr != [NSNull null] ) {
			for( Product* prod in arr ) {
				if( [[prod.productName lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 ) {
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



#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark Email Report
#pragma mark -
/*
 *
 */
- (void) emailReport {
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		// Company Info
		Company *company = [[PSADataManager sharedInstance] getCompany];
		// Set up the recipients
		if( company.companyEmail ) {
			NSArray *toRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
			[picker setToRecipients:toRecipients];
		}
		// Subject
		NSString *subject = [[NSString alloc] initWithFormat:@"%@ Product Inventory", (company.companyName) ? company.companyName : @""];
		[picker setSubject:subject];
		[subject release];
		// HTML message
		NSString *companyInfo = [company getMutlilineHTMLString];
		// Static Top
		NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%@%@", 
									@"<html> <head> <style TYPE=\"text/css\"> BODY, TD { font-family: Helvetica, Verdana, Arial, Geneva; font-size: 12px; } .total { color: #333333; } </style> </head> <body> <table width=\"95%\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" align=\"center\"> <tr> <td> <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\"> <tr> <td valign=\"top\"><font size=\"5\"><b>",
									(company.companyName) ? company.companyName : @"",
									@"</b></font> <br/>", 
									(companyInfo) ? companyInfo : @"", 
									@"</td> <td align=\"right\" valign=\"top\"> <font size=\"5\" color=\"#6b6b6b\"><b>",
									@"Product Inventory</b></font> <br/>Date: ",
									[[PSADataManager sharedInstance] getStringForAppointmentDate:[NSDate date]],
									@"</td> </tr> </table> </td> </tr>"
									];
		
		for( NSString *key in [products allKeys] ) {
			[message appendFormat:@"%@%@%@",
			 @"<tr><td>&nbsp;</td></tr> <tr> <td> <font size=\"3\" color=\"#6b6b6b\"><b>",
			 key,
			 @"</b></font><br/><br/> <table width=\"100%\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\"> <tr align=\"right\"> <td width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Prod Num.</b> </td> <td align=\"left\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Product Name</b> </td> <td width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Cost</b> </td> <td width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Price</b> </td> <td width=\"80\" width=\"150\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Min.</b> </td> <td width=\"80\" width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>In Stock</b> </td> <td width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Max.</b> </td> <td width=\"80\" align=\"right\" style=\"border-bottom:solid 1px #cccccc;\"> <b>Order</b> </td> </tr>"
			 ];
			NSArray *prods = [products objectForKey:key];
			for( Product *tmp in prods ) {
				[message appendFormat:@"%@%@ %@%@ %@%@ %@%@ %@%d %@%d %@%d %@%d %@",
				 @"<tr align=\"right\"><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-left:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productNumber,
				 @"</td><td align=\"left\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productName,
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:tmp.productCost],
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 [formatter stringFromNumber:tmp.productPrice],
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productMin,
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productInStock,
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productMax,
				 @"</td><td align=\"right\" style=\"border-bottom:solid 1px #cccccc; border-right:solid 1px #cccccc;\">",
				 tmp.productMax-tmp.productInStock,
				 @"</td></tr>"
				 ];
			}
			[message appendString:@"</table></td></tr>"];
		}
		
		[message appendString:@"</table></body></html>"];
		
		[picker setMessageBody:message isHTML:YES];
		[message release];
		[company release];
		// Present the mail composition interface. 
		[self presentViewController:picker animated:YES completion:nil]; 
		[picker release];
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Report!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}


@end
