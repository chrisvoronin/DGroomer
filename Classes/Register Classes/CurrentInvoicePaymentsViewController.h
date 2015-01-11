//
//  CurrentInvoicePaymentsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 4/9/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>


@interface CurrentInvoicePaymentsViewController : UIViewController <PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSNumberFormatter	*formatter;
	NSArray				*payments;
	UITableViewCell		*paymentCell;
	UITableView			*tblPayments;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*paymentCell;
@property (nonatomic, retain) IBOutlet UITableView		*tblPayments;

- (void) releaseAndRepopulatePayments;

@end
