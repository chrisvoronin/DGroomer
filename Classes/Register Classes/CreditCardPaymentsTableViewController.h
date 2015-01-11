//
//  CreditCardPaymentsTableViewController.h
//  PSA
//
//  Created by David J. Maier on 5/26/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Report;

@interface CreditCardPaymentsTableViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UITableViewCell		*ccPaymentsCell;
	NSDictionary		*payments;
	UISegmentedControl	*segViewOptions;
	NSArray				*sortedKeys;
	UITableView			*tblPayments;
	// Leave nil if not generating a report
	Report				*report;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl	*segViewOptions;
@property (nonatomic, retain) IBOutlet UITableView			*tblPayments;
@property (nonatomic, assign) IBOutlet UITableViewCell		*ccPaymentsCell;
@property (nonatomic, retain) Report						*report;

- (void)		emailReport;
- (void)		getPayments;
- (IBAction)	segViewOptionsChanged:(id)sender;
- (void)		setSortedKeys;



@end
