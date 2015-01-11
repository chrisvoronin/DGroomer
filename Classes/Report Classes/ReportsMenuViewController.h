//
//  ReportsMenuViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReportsMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView	*tblReports;
}

@property (nonatomic, retain) IBOutlet UITableView	*tblReports;


@end
