//
//  TransactionsTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/16/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Report;

@interface TransactionsTableViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDelegate, UITableViewDataSource> 
{
	NSNumberFormatter	*formatter;
	UISegmentedControl	*segViewOptions;
	NSArray				*sortedKeys;
	UITableView			*tblTransactions;
	NSDictionary		*transactions;
	UITableViewCell		*transactionsCell;
	// Leave nil if not generating a Transaction report
	Report				*report;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl	*segViewOptions;
@property (nonatomic, retain) IBOutlet UITableView			*tblTransactions;
@property (nonatomic, assign) IBOutlet UITableViewCell		*transactionsCell;
@property (nonatomic, retain) Report						*report;

- (void)		emailReport;
- (void)		getTransactions;
- (IBAction)	segViewOptionsChanged:(id)sender;
- (void)		setSortedKeys;


@end
