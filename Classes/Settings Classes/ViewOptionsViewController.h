//
//  ViewOptionsViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/7/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface ViewOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView	*tblOptions;
	Settings				*settings;
}

@property (nonatomic, retain) UITableView	*tblOptions;

- (void) save:(id)sender;

@end
