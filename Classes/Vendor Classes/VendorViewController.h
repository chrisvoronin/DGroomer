//
//  VendorViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Vendor;

@interface VendorViewController : UIViewController 
<MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> 
{
	UITableView	*tblVendor;
	Vendor		*vendor;
}

@property (nonatomic, retain) IBOutlet UITableView	*tblVendor;
@property (nonatomic, retain) Vendor				*vendor;

- (void) edit;


@end
