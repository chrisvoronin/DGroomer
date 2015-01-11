//
//  GiftCertificateTableViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiftCertificate;

// Protocol Definition
@protocol PSAGiftCertificateTableDelegate <NSObject>
@required
- (void) selectionMadeWithCertificate:(GiftCertificate*)theCertificate;
@end

@interface GiftCertificateTableViewController : UIViewController <PSAGiftCertificateTableDelegate, UITableViewDataSource, UITableViewDelegate> {
	UITableViewCell		*certificateCell;
	NSArray				*certificates;
	id					delegate;
	NSNumberFormatter	*formatter;
	UITableView			*tblCertificates;
}

@property (nonatomic, assign) id <PSAGiftCertificateTableDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableViewCell	*certificateCell;
@property (nonatomic, retain) IBOutlet UITableView		*tblCertificates;

@end
