//
//  GiftCertificateAmountViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class GiftCertificate;

@interface GiftCertificateAmountViewController : PSABaseViewController {
	GiftCertificate	*certificate;
	UITextField		*txtAmount;
}

@property (nonatomic, retain) GiftCertificate		*certificate;
@property (nonatomic, retain) IBOutlet UITextField	*txtAmount;

- (void) done;

@end
