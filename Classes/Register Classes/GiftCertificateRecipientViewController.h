//
//  GiftCertificateRecipientViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class GiftCertificate;

@interface GiftCertificateRecipientViewController : PSABaseViewController {
	GiftCertificate	*certificate;
	UITextField		*txtFirst;
	UITextField		*txtLast;
}

@property (nonatomic, retain) GiftCertificate		*certificate;
@property (nonatomic, retain) IBOutlet UITextField	*txtFirst;
@property (nonatomic, retain) IBOutlet UITextField	*txtLast;

- (void) done;


@end
