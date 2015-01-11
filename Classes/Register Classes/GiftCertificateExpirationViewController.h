//
//  GiftCertificateExpirationViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class GiftCertificate;

@interface GiftCertificateExpirationViewController : PSABaseViewController {
	GiftCertificate	*certificate;
	UIDatePicker	*datePicker;
}

@property (nonatomic, retain) GiftCertificate		*certificate;
@property (nonatomic, retain) IBOutlet UIDatePicker	*datePicker;

- (void) done;

@end
