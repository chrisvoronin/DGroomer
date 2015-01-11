//
//  ServiceCostController.h
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Service;

@interface ServiceCostViewController : PSABaseViewController {
	IBOutlet UITextField *txtCost;
	IBOutlet UITextField *txtFee;
	IBOutlet UITextField *txtPrice;
	IBOutlet UISegmentedControl	*segFlatOrHourly;
	IBOutlet UISwitch *swTaxable;
	Service	*service;
}

@property (nonatomic, retain) UITextField	*txtCost;
@property (nonatomic, retain) UITextField	*txtFee;
@property (nonatomic, retain) UITextField	*txtPrice;
@property (nonatomic, retain) UISwitch		*swTaxable;
@property (nonatomic, retain) Service		*service;
@property (nonatomic, retain) UISegmentedControl	*segFlatOrHourly;

- (void) save;

@end
