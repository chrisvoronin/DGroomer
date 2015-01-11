//
//  SettingsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 7/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	*settingsTable;
}

@property (nonatomic, retain) UITableView	*settingsTable;


@end
