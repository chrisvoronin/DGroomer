//
//  ServicesInformation.h
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ServiceGroupsTableViewController.h"
#import <UIKit/UIKit.h>

@class Service;

@interface ServiceInformationController : UIViewController<UITableViewDelegate, UITableViewDataSource, PSAServiceGroupsTableDelegate> {
	NSNumberFormatter		*formatter;
	IBOutlet UITableView	*myTableView;
	Service					*service;
}

@property (nonatomic, retain) UITableView	*myTableView;
@property (nonatomic, retain) Service		*service;

- (void) save;
- (void) cancelService;
@end
