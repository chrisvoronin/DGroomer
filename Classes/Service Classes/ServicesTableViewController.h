//
//  ServiceViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "PSADataManager.h"
#import <UIKit/UIKit.h>

@class Service;

// Protocol Definition
@protocol PSAServiceTableDelegate <NSObject>
@required
- (void) selectionMadeWithService:(Service*)theService;
@end

@interface ServicesTableViewController : UIViewController <PSADataManagerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, PSAServiceTableDelegate> {
	NSNumberFormatter		*formatter;
	IBOutlet UITableView	*myTableView;
	NSDictionary			*services;
	NSArray					*sortedKeys;
	NSIndexPath				*serviceToDelete;
	id						serviceDelegate;
	IBOutlet UISegmentedControl	*segActive;
	// Search
	NSMutableArray				*filteredList;
	UITableView					*tableDeleting;
}

@property (nonatomic, retain) UITableView			*myTableView;
@property (nonatomic, retain) UISegmentedControl	*segActive;
@property (nonatomic, assign) id <PSAServiceTableDelegate>	serviceDelegate;

- (void)		addService;
- (void)		releaseAndRepopulateServices;
- (IBAction)	segActiveValueChanged:(id)sender;
- (void)        cancelService;

@end

