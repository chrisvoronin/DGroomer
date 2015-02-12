//
//  CompanyViewController.h
//  myBusiness
//
//  Created by David J. Maier on 8/2/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Company;

@interface CompanyViewController : PSABaseViewController {
	IBOutlet UITextField *owner;
	IBOutlet UITextField *name;
	IBOutlet UITextField *addr1;
	IBOutlet UITextField *addr2;
	IBOutlet UITextField *city;
	IBOutlet UITextField *state;
	IBOutlet UITextField *zip;
	IBOutlet UITextField *phone;
	IBOutlet UITextField *fax;
	IBOutlet UITextField *email;
	IBOutlet UIScrollView *myScrollView;
	//
	Company		*company;
}

@property (nonatomic, retain) UIScrollView *myScrollView;

@property (nonatomic, retain) UITextField *owner;
@property (nonatomic, retain) UITextField *name;
@property (nonatomic, retain) UITextField *addr1;
@property (nonatomic, retain) UITextField *addr2;
@property (nonatomic, retain) UITextField *city;
@property (nonatomic, retain) UITextField *state;
@property (nonatomic, retain) UITextField *zip;
@property (nonatomic, retain) UITextField *phone;
@property (nonatomic, retain) UITextField *fax;
@property (nonatomic, retain) UITextField *email;

@property (nonatomic, assign) id currentResponder;
- (void) save;

@end
