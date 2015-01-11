//
//  ProductHistoryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 2/3/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Report;

@interface ProductHistoryViewController : UIViewController <MFMailComposeViewControllerDelegate, PSADataManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
	UITableViewCell	*productHistoryCell;
	NSArray			*products;
	Report			*report;
	UITableView		*tblProducts;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*productHistoryCell;
@property (nonatomic, retain) NSArray					*products;
@property (nonatomic, retain) Report					*report;
@property (nonatomic, retain) IBOutlet UITableView		*tblProducts;

- (void) emailReport;

@end
