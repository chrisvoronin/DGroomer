//
//  ProjectNameEntryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectInvoice;

@interface ProjectNameEntryViewController : UIViewController {
	ProjectInvoice	*invoice;
	Project			*project;
	UITextField		*txtField;
}

@property (nonatomic, retain) IBOutlet UITextField	*txtField;
@property (nonatomic, retain) ProjectInvoice		*invoice;
@property (nonatomic, retain) Project				*project;

- (void) done;


@end
