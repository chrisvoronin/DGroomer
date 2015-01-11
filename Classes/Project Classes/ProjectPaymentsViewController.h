//
//  ProjectPaymentsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/26/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, Transaction;

@interface ProjectPaymentsViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSNumberFormatter	*formatter;
	Project			*project;
	Transaction		*transaction;
	UITableView		*tblPayments;
	UITableViewCell	*cellPayment;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*cellPayment;
@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) IBOutlet UITableView		*tblPayments;

- (void) add;

@end
