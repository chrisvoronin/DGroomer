//
//  RegisterViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/15/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegisterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView	*tblRegister;
}

@property (nonatomic, retain) IBOutlet UITableView	*tblRegister;

@end
