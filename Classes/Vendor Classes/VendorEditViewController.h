//
//  VendorViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Vendor;

@interface VendorEditViewController : UIViewController {
    IBOutlet UIScrollView *myScrollView;
    IBOutlet UITextField *address1;
    IBOutlet UITextField *address2;
    IBOutlet UITextField *city;
    IBOutlet UITextField *contact;
    IBOutlet UITextField *email;
    IBOutlet UITextField *faxNumber;
    IBOutlet UITextField *name;
    IBOutlet UITextField *phoneNumber;
    IBOutlet UITextField *state;
    IBOutlet UITextField *zipcode;

	Vendor	*vendor;
}

@property (nonatomic, retain) Vendor		*vendor;
@property (nonatomic, retain) UIScrollView	*myScrollView;
@property (nonatomic, retain) UITextField	*address1;
@property (nonatomic, retain) UITextField	*address2;
@property (nonatomic, retain) UITextField	*city;
@property (nonatomic, retain) UITextField	*contact;
@property (nonatomic, retain) UITextField	*email;
@property (nonatomic, retain) UITextField	*faxNumber;
@property (nonatomic, retain) UITextField	*name;
@property (nonatomic, retain) UITextField	*phoneNumber;
@property (nonatomic, retain) UITextField	*state;
@property (nonatomic, retain) UITextField	*zipcode;


@property (nonatomic, assign) id currentResponder;

- (void) save;

@end