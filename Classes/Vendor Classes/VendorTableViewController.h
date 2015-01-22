//
//  VendorTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 7/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Vendor;

// Protocol Definition
@protocol PSAVendorTableDelegate <NSObject>
@required
- (void) selectionMadeWithVendor:(Vendor*)theVendor;
@end

@interface VendorTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, PSAVendorTableDelegate> {
	IBOutlet UITableView	*myTableView;
	NSArray					*vendors;
	id						delegate;
	NSIndexPath				*vendorToDelete;
}

@property (nonatomic, retain) UITableView	*myTableView;
@property (nonatomic, retain) NSArray		*vendors;
@property (nonatomic, assign) id <PSAVendorTableDelegate> delegate;

- (void) addVendor;
- (void) cancelEdit;
@end
