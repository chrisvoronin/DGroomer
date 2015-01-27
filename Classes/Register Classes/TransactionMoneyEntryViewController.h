//
//  TransactionMoneyEntryViewController.h
//  myBusiness
//
//  Created by David J. Maier on 1/6/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

// Protocol Definition
@protocol PSATransactionMoneyEntryDelegate <NSObject>
@required
- (void) completedMoneyEntry:(NSString*)value title:(NSString*)title;
@end

@interface TransactionMoneyEntryViewController : PSABaseViewController {
	id				delegate;

    IBOutlet UILabel *lbBalance;
	NSString		*value;
	UITextField		*txtAmount;
}

@property (nonatomic, assign) id <PSATransactionMoneyEntryDelegate> delegate;
@property (nonatomic, retain) IBOutlet UILabel		*lbBalance;
@property (nonatomic, retain) NSString				*value;
@property (nonatomic, retain) IBOutlet UITextField	*txtAmount;

- (void) done;

@end
