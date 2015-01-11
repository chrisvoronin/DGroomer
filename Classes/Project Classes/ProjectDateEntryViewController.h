//
//  ProjectDateEntryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/21/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectInvoice;

@interface ProjectDateEntryViewController : UIViewController {
	IBOutlet UIDatePicker	*datePicker;
	IBOutlet UILabel		*lbDescription;
	ProjectInvoice			*invoice;
	Project					*project;
}

@property (nonatomic, retain) ProjectInvoice	*invoice;
@property (nonatomic, retain) Project			*project;
@property (nonatomic, retain) UILabel			*lbDescription;
@property (nonatomic, retain) UIDatePicker		*datePicker;

- (void) done;

@end
