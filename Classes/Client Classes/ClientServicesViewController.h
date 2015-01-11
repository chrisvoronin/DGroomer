//
//  ClientServicesViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import "PSAAppDelegate.h"
#import <UIKit/UIKit.h>

@class Client;

@interface ClientServicesViewController : GenericClientDetailViewController <PSADataManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSArray					*appointments;
	IBOutlet UITableView	*tblServices;
}

@property (nonatomic, retain) UITableView	*tblServices;

- (IBAction) addAppointmentButtonTouchUp;

@end
