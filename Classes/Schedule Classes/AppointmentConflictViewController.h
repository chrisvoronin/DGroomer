//
//  AppointmentConflictViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol Definition
@protocol PSAAppointmentConflictDelegate <NSObject>
@required
- (void) delegateShouldPop;
@end

@interface AppointmentConflictViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray					*conflicts;
	NSMutableArray			*conflictSelections;
	id						delegate;
	UIView					*headerView;
	IBOutlet UITableView	*tblConflicts;
}

@property (nonatomic, retain) NSArray		*conflicts;
@property (nonatomic, retain) UITableView	*tblConflicts;
@property (nonatomic, assign) id <PSAAppointmentConflictDelegate> delegate;

@end
