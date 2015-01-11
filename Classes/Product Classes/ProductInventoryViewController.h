//
//  ProductInventoryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/30/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "TablePickerViewController.h"
#import <UIKit/UIKit.h>

@class Product, ProductAdjustment;

@interface ProductInventoryViewController : UIViewController 
<PSATablePickerDelegate, UITableViewDelegate, UITableViewDataSource> 
{
	ProductAdjustment	*adjustment;
	NSArray				*adjustmentValues;
	Product				*product;
	UITableView			*tblInventory;
}

@property (nonatomic, retain) ProductAdjustment		*adjustment;
@property (nonatomic, retain) Product				*product;
@property (nonatomic, retain) IBOutlet UITableView	*tblInventory;

- (void) save;


@end
