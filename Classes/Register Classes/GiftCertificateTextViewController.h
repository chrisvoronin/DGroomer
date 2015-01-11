//
//  GiftCertificateTextViewController.h
//  myBusiness
//
//  Created by David J. Maier on 12/28/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class GiftCertificate;

@interface GiftCertificateTextViewController : PSABaseViewController {
	GiftCertificate	*certificate;
	BOOL			editing;
	UITextView		*tvText;
}

@property (nonatomic, retain) GiftCertificate		*certificate;
@property (nonatomic, assign) BOOL					editing;
@property (nonatomic, retain) IBOutlet UITextView	*tvText;

- (void) done;



@end
