//
//  AddServicesNameController.h
//  myBusiness
//
//  Created by David J. Maier on 7/13/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Service;

@interface ServiceNameViewController : PSABaseViewController {
	IBOutlet UITextField	*txtName;
	IBOutlet UISwitch		*swActive;
	Service	*service;
    
}

@property (nonatomic, retain) UISwitch		*swActive;
@property (nonatomic, retain) UITextField	*txtName;
@property (nonatomic, retain) Service		*service;

- (void) save;

@end
