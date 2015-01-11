//
//  ProductInventoryQuantityViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/12/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class ProductAdjustment;

@interface ProductInventoryQuantityViewController : PSABaseViewController {
	ProductAdjustment	*adjustment;
	UITextField			*txtQuantity;
}

@property (nonatomic, retain) ProductAdjustment		*adjustment;
@property (nonatomic, retain) IBOutlet UITextField	*txtQuantity;

- (void) done;

@end
