//
//  ProductAmountContoller.h
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Product;

@interface ProductAmountViewController : PSABaseViewController {
	IBOutlet UITextField	*prodMin;
	IBOutlet UITextField	*prodMax;
	Product					*product;
}

@property (nonatomic, retain) UITextField	*prodMin;
@property (nonatomic, retain) UITextField	*prodMax;
@property (nonatomic, retain) Product		*product;


- (void) save;

@end
