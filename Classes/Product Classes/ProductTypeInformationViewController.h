//
//  ProductTypeInformationViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class ProductType;

@interface ProductTypeInformationViewController : PSABaseViewController {
	IBOutlet UITextField	*txtField;
	ProductType	*type;
}

@property (nonatomic, retain) UITextField	*txtField;
@property (nonatomic, retain) ProductType	*type;

- (void) save;
- (void) cancelAdd;
@end
