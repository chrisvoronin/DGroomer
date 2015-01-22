//
//  AddRatesController.h
//  myBusiness
//
//  Created by David J. Maier on 8/2/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Company;

@interface CommissionTaxViewController : PSABaseViewController {
	
	IBOutlet UITextField *commissionRate;
	IBOutlet UITextField *saleTaxPercent;

	Company		*company;
	BOOL		newCompany;
}

//@property (nonatomic, retain) UITextField *commissionRate;
@property (nonatomic, retain) UITextField *saleTaxPercent;


- (void) save;

@end
