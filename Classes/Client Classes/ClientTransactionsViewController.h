//
//  ClientHistoryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import "PSADataManager.h"
#import <UIKit/UIKit.h>


@interface ClientTransactionsViewController : GenericClientDetailViewController <PSADataManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSNumberFormatter	*formatter;
	UITableView			*tblTransactions;
	NSArray				*transactions;
	UITableViewCell		*transactionsCell;
}

@property (nonatomic, retain) IBOutlet UITableView			*tblTransactions;
@property (nonatomic, assign) IBOutlet UITableViewCell		*transactionsCell;

@end
