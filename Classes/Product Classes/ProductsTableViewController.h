//
//  ProductViewController.h
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Product;

// Protocol Definition
@protocol PSAProductTableDelegate <NSObject>
@required
- (void) selectionMadeWithProduct:(Product*)theProduct;
@end

@interface ProductsTableViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, PSAProductTableDelegate, UISearchDisplayDelegate, UISearchBarDelegate> 
{
	NSNumberFormatter			*formatter;
	IBOutlet UITableView		*myTableView;
	NSIndexPath					*productToDelete;
	id							productDelegate;
	IBOutlet UISegmentedControl	*segActive;
	NSDictionary				*products;
	NSArray						*sortedKeys;
	// Search
	NSMutableArray				*filteredList;
	UITableView					*tableDeleting;
	// Inventory Report
	BOOL						isInventoryReport;
	UITableViewCell				*productInventoryCell;
}

@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) UISegmentedControl			*segActive;
@property (nonatomic, assign) id <PSAProductTableDelegate>	productDelegate;
@property (nonatomic, assign) BOOL							isInventoryReport;
@property (nonatomic, assign) IBOutlet UITableViewCell		*productInventoryCell;

- (void)		emailReport;
- (void)		releaseAndRepopulateProducts;
- (IBAction)	segActiveValueChanged:(id)sender;
- (void)        cancelEdit;
@end
