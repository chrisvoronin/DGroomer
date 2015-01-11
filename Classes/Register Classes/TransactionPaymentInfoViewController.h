//
//  TransactionPaymentInfoViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@interface TransactionPaymentInfoViewController : PSABaseViewController {
	TransactionPayment	*payment;
	UILabel				*lbFieldName;
	UILabel				*lbInstructions;
	UITextField			*txtInfo;
}

@property (nonatomic, retain) TransactionPayment	*payment;
@property (nonatomic, retain) IBOutlet UILabel		*lbFieldName;
@property (nonatomic, retain) IBOutlet UILabel		*lbInstructions;
@property (nonatomic, retain) IBOutlet UITextField	*txtInfo;

- (void) done;

@end
