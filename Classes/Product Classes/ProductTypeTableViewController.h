//
//  ProductTypeTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/5/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductType;

// Protocol Definition
@protocol PSAProductTypeTableDelegate <NSObject>
@required
- (void) selectionMadeWithProductType:(ProductType*)theType;
@end

@interface ProductTypeTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, PSAProductTypeTableDelegate> {
	IBOutlet UITableView	*myTableView;
	NSIndexPath				*typeToDelete;
	id						typeDelegate;
	NSArray					*types;
}

@property (nonatomic, retain) UITableView	*myTableView;
@property (nonatomic, assign) id <PSAProductTypeTableDelegate>	typeDelegate;

- (void) addProductType;

@end
