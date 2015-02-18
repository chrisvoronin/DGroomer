//
//  GiftCertificateViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "ClientTableViewController.h"
#import <UIKit/UIKit.h>

@class GiftCertificate, Transaction;

// Protocol Definition
@protocol PSAGiftCertificateDelegate <NSObject>
@required
- (void) completedNewGiftCertificate:(GiftCertificate*)theCert;
@end

@interface GiftCertificateViewController : UIViewController <PSAClientTableDelegate, UITableViewDataSource, UITableViewDelegate> {
	GiftCertificate		*certificate;
	id					delegate;
	NSNumberFormatter	*formatter;
	BOOL				isEditing;
	// newID specifies a unique ID < 0 for a new certificate
	NSInteger		newID;
	UITableView		*tblCertificate;
	// A new certificate can only be added to a Transaction
	Transaction		*transaction;
}

@property (nonatomic, retain) GiftCertificate		*certificate;
@property (nonatomic, assign) id <PSAGiftCertificateDelegate> delegate;
@property (nonatomic, assign) NSInteger				newID;
@property (nonatomic, retain) IBOutlet UITableView	*tblCertificate;
@property (nonatomic, retain) Transaction			*transaction;

- (void) save;
- (void) cancelEdit;

@end
