//
//  ServiceGroupsTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/10/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServiceGroup;

// Protocol Definition
@protocol PSAServiceGroupsTableDelegate <NSObject>
@required
- (void) selectionMadeWithServiceGroup:(ServiceGroup*)theGroup;
@end

@interface ServiceGroupsTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, PSAServiceGroupsTableDelegate> {
	IBOutlet UITableView	*myTableView;
	id						delegate;
	NSArray					*groups;
	NSIndexPath				*groupToDelete;
}

@property (nonatomic, retain) UITableView	*myTableView;
@property (nonatomic, assign) id <PSAServiceGroupsTableDelegate> delegate;

- (void) addServiceGroup;


@end
