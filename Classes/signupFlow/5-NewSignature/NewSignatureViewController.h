//
//  NewSignatureViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureCanvas.h"
#import "NewConfirmationViewController.h"

@protocol SignatureCompleteDelegate
- (void) signatureCompleted;
@end

@interface NewSignatureViewController : UIViewController


-(id)initWithMerchantKey:(long)mKey andFullName:(NSString*)fName;
@property (retain, nonatomic) UINavigationController* parentNavigationControl;
@property (retain, nonatomic) IBOutlet UILabel *lblFullName;

@property (retain, nonatomic) IBOutlet SignatureCanvas *imgViewSignaturePad;
@property (nonatomic, assign) id<SignatureCompleteDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *imgSign;

@end
