//
//  ProjectNotesEntryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/19/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProjectInvoice, Project;

@interface ProjectNotesEntryViewController : UIViewController {
	ProjectInvoice	*invoice;
	Project			*project;
	UITextView		*tvText;
}

@property (nonatomic, retain) ProjectInvoice		*invoice;
@property (nonatomic, retain) Project				*project;
@property (nonatomic, retain) IBOutlet UITextView	*tvText;

- (void) done;


@end
