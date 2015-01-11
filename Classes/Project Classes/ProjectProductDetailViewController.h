//
//  ProjectProductDetailViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectProduct;

@interface ProjectProductDetailViewController : UIViewController <UIActionSheetDelegate> {
	BOOL			isModal;
	Project			*project;
	ProjectProduct	*projectProduct;
	// Interface
	UILabel					*lbDiscount;
	UILabel					*lbDollarSign;
	UILabel					*lbTotal;
	UISegmentedControl		*segPercent;
	UISegmentedControl		*segTax;
	UITextField				*txtDiscount;
	UITextField				*txtPrice;
	UITextField				*txtQuantity;
}

@property (nonatomic, assign) BOOL				isModal;
@property (nonatomic, retain) Project			*project;
@property (nonatomic, retain) ProjectProduct	*projectProduct;

@property (nonatomic, retain) IBOutlet UILabel	*lbDiscount;
@property (nonatomic, retain) IBOutlet UILabel	*lbDollarSign;
@property (nonatomic, retain) IBOutlet UILabel	*lbTotal;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segPercent;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segTax;
@property (nonatomic, retain) IBOutlet UITextField			*txtDiscount;
@property (nonatomic, retain) IBOutlet UITextField			*txtPrice;
@property (nonatomic, retain) IBOutlet UITextField			*txtQuantity;


- (void)		relabel;
- (void)		relabelWithDiscount:(NSString*)discountText;
- (void)		relabelWithDiscount:(NSString*)discountText quantity:(NSString*)quantityText price:(NSString*)priceText;
- (void)		relabelWithPrice:(NSString*)priceText;
- (void)		relabelWithQuantity:(NSString*)quantityText;
- (IBAction)	valueChanged:(id)sender;

- (void)		save;

@end
