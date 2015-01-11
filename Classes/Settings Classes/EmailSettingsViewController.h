//
//  EmailSettingsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 2/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmailSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	*tblEmail;
}

@property (nonatomic, retain) UITableView	*tblEmail;

@end
