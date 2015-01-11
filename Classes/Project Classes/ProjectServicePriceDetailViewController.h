//
//  ProjectServiceViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/23/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectService;

@interface ProjectServicePriceDetailViewController : UIViewController <UIActionSheetDelegate> {
	BOOL			isModal;
	Project			*project;
	ProjectService	*projectService;
	// Interface
	UILabel					*lbDiscount;
	UILabel					*lbDollarSign;
	UILabel					*lbDollarSignSetup;
	UILabel					*lbTotal;
	UISegmentedControl		*segFlatRate;
	UISegmentedControl		*segPercent;
	UITextField				*txtDiscount;
	UITextField				*txtPrice;
	UITextField				*txtSetupFee;
}

@property (nonatomic, assign) BOOL				isModal;
@property (nonatomic, retain) Project			*project;
@property (nonatomic, retain) ProjectService	*projectService;

@property (nonatomic, retain) IBOutlet UILabel				*lbDiscount;
@property (nonatomic, retain) IBOutlet UILabel				*lbDollarSign;
@property (nonatomic, retain) IBOutlet UILabel				*lbDollarSignSetup;
@property (nonatomic, retain) IBOutlet UILabel				*lbTotal;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segFlatRate;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segPercent;
@property (nonatomic, retain) IBOutlet UITextField			*txtDiscount;
@property (nonatomic, retain) IBOutlet UITextField			*txtPrice;
@property (nonatomic, retain) IBOutlet UITextField			*txtSetupFee;

- (void)		relabel;
- (void)		relabelWithDiscount:(NSString*)discountText;
- (void)		relabelWithDiscount:(NSString*)discountText setup:(NSString*)setupText price:(NSString*)priceText;
- (void)		relabelWithPrice:(NSString*)priceText;
- (void)		relabelWithSetup:(NSString*)setupText;
- (IBAction)	valueChanged:(id)sender;

- (void)		save;

@end
