//
//  CloseoutHistoryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 2/2/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Report;

@interface CloseoutHistoryViewController : UIViewController <MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	UITableViewCell		*closeoutCell;
	NSArray				*closeouts;
	NSNumberFormatter	*formatter;
	Report				*report;
	UITableView			*tblCloseouts;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*closeoutCell;
@property (nonatomic, retain) NSArray					*closeouts;
@property (nonatomic, retain) Report					*report;
@property (nonatomic, retain) IBOutlet UITableView		*tblCloseouts;

- (void) emailReport;

@end
