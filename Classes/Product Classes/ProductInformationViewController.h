//
//  ProductsInformationController.h
//  myBusiness
//
//  Created by David J. Maier on 7/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ProductTypeTableViewController.h"
#import "VendorTableViewController.h"
#import "PSABaseViewController.h"
#import <UIKit/UIKit.h>
#import "ProductStockTableViewCell.h"
@class Product;

@interface ProductInformationViewController : PSABaseViewController <UITableViewDelegate, UITableViewDataSource, PSAProductTypeTableDelegate, PSAVendorTableDelegate> {
	NSNumberFormatter		*formatter;
	IBOutlet UITableView	*myTableView;
	Product					*product;
}

@property (retain, nonatomic) IBOutlet ProductStockTableViewCell *stockCell;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) Product	*product;

- (void) save;
- (void) cancelEdit;
- (void) setTitleName:(NSString*)strName;
@end
