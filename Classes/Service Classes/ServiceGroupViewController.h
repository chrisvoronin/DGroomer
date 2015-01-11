//
//  AddGroupController.h
//  myBusiness
//
//  Created by David J. Maier on 6/14/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class ServiceGroup;

@interface ServiceGroupViewController : PSABaseViewController {
	IBOutlet UITextField	*txtGroupName;
	ServiceGroup			*group;
}

@property (nonatomic, retain) UITextField	*txtGroupName;
@property (nonatomic, retain) ServiceGroup	*group;


- (void) save;

@end
