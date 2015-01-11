//
//  ProductNameController.h
//  myBusiness
//
//  Created by David J. Maier on 7/20/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Product;

@interface ProductNameViewController : PSABaseViewController {
	IBOutlet UITextField	*prodName;
	IBOutlet UITextField	*prodNum;
	IBOutlet UISwitch		*swActive;
	Product *product;
}

@property (nonatomic, retain) UISwitch		*swActive;
@property (nonatomic, retain) UITextField	*prodName;
@property (nonatomic, retain) UITextField	*prodNum;
@property (nonatomic, retain) Product		*product;

- (void) save;

@end
