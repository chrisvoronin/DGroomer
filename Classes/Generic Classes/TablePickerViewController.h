//
//  TablePickerViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol Definition
@protocol PSATablePickerDelegate <NSObject>
@required
- (void) selectionMadeWithString:(NSString*)theValue;
@end

@interface TablePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	id						pickerDelegate;
	NSArray					*pickerValues;
	IBOutlet UITableView	*tblItems;
	NSIndexPath				*selectedRow;
	NSString				*selectedValue;
}


@property (nonatomic, assign) id <PSATablePickerDelegate> pickerDelegate;
@property (nonatomic, retain) NSArray		*pickerValues;
@property (nonatomic, retain) NSString		*selectedValue;
@property (nonatomic, retain) UITableView	*tblItems;


@end
