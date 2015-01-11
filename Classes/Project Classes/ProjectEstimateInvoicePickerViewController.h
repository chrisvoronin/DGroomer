//
//  ProjectEstimateInvoicePickerViewController.h
//  myBusiness
//
//  Created by David J. Maier on 4/11/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project, ProjectProduct, ProjectService;

@interface ProjectEstimateInvoicePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	NSNumberFormatter	*formatter;
	NSMutableArray	*selectionsEstimates;
	NSMutableArray	*selectionsInvoices;
	Project			*project;
	ProjectProduct	*product;
	ProjectService	*service;
	UITableView		*tblInvoices;
	UITableViewCell	*cellInvoice;
}

@property (nonatomic, assign) IBOutlet UITableViewCell	*cellInvoice;
@property (nonatomic, retain) Project					*project;
@property (nonatomic, retain) ProjectProduct			*product;
@property (nonatomic, retain) ProjectService			*service;
@property (nonatomic, retain) IBOutlet UITableView		*tblInvoices;

- (void) done;

@end
