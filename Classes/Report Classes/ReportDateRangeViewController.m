//
//  ReportDateRangeViewController.m
//  PSA
//
//  Created by David J. Maier on 1/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import "ReportDateRangeViewController.h"


@implementation ReportDateRangeViewController

@synthesize datePicker, tblRanges;

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.datePicker = nil;
	self.tblRanges = nil;
    [super dealloc];
}

- (void) generate {
	
}


@end
