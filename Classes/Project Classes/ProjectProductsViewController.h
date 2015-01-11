//
//  ProjectProductsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductsTableViewController.h"
#import <UIKit/UIKit.h>

@class Project;

@interface ProjectProductsViewController : UIViewController
<PSAProductTableDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
	NSNumberFormatter	*formatter;
	Project			*project;
	UITableView		*tblProducts;
	UITableViewCell	*cellProduct;
	//
	ProjectProduct	*toDelete;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*cellProduct;
@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) IBOutlet UITableView		*tblProducts;

- (void) add;
- (void) deleteProduct;

@end
