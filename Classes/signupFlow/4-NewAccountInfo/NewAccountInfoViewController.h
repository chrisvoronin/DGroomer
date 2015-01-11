//
//  NewAccountInfoViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermsAndConditionsViewController.h"
#import "NewSignatureViewController.h"
#import "BaseRegistrationViewController.h"

@interface NewAccountInfoViewController : BaseRegistrationViewController<SignatureCompleteDelegate>

-(id)initWithMerchantKey:(long)mKey;

@property (strong, nonatomic) IBOutlet UIView *view_DepositFund;

@end
