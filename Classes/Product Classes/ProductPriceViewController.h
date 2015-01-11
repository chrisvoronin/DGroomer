//
//  ProductPriceController.h
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Product;

@interface ProductPriceViewController : PSABaseViewController {
	IBOutlet UITextField	*prodCost;
	IBOutlet UITextField	*prodPrice;
	IBOutlet UISwitch		*tax;
	Product					*product;
}

@property (nonatomic, retain) UITextField	*prodCost;
@property (nonatomic, retain) UITextField	*prodPrice;
@property (nonatomic, retain) UISwitch		*tax;
@property (nonatomic, retain) Product		*product;

- (void) save;

@end
