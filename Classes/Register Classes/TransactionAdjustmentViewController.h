//
//  TransactionAdjustmentViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class TransactionItem;

@interface TransactionAdjustmentViewController : PSABaseViewController {
	TransactionItem			*transactionItem;
	UISegmentedControl		*segPercent;
	UISegmentedControl		*segTax;
	Transaction				*transaction;
	UITextField				*txtDiscount;
	UITextField				*txtPrice;
	UITextField				*txtQuantity;
	UITextField				*txtSetupFee;
	
	// Labels
	UILabel	*lbDiscount;
	UILabel	*lbDollarSign;
	UILabel	*lbSetup;
	UILabel *lbSetupDollarSign;
	UILabel	*lbTotal;
}

@property (nonatomic, retain) TransactionItem				*transactionItem;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segPercent;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segTax;
@property (nonatomic, retain) Transaction					*transaction;
@property (nonatomic, retain) IBOutlet UITextField			*txtDiscount;
@property (nonatomic, retain) IBOutlet UITextField			*txtPrice;
@property (nonatomic, retain) IBOutlet UITextField			*txtQuantity;
@property (nonatomic, retain) IBOutlet UITextField			*txtSetupFee;

@property (nonatomic, retain) IBOutlet UILabel	*lbDiscount;
@property (nonatomic, retain) IBOutlet UILabel	*lbDollarSign;
@property (nonatomic, retain) IBOutlet UILabel	*lbSetup;
@property (nonatomic, retain) IBOutlet UILabel	*lbSetupDollarSign;
@property (nonatomic, retain) IBOutlet UILabel	*lbTotal;

- (void)		done;
- (void)		relabel;
- (void)		relabelWithDiscount:(NSString*)discountText;
- (void)		relabelWithDiscount:(NSString*)discountText quantity:(NSString*)quantityText price:(NSString*)priceText setupFee:(NSString*)setupText;
- (void)		relabelWithQuantity:(NSString*)quantityText;
- (void)		relabelWithPrice:(NSString*)priceText;
- (void)		relabelWithSetupFee:(NSString*)setupText;
- (IBAction)	valueChanged:(id)sender;


@end
