//
//  NewBusinessInfoViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRegistrationViewController.h"
#import "NewPrincipalInfoViewController.h"

@interface NewBusinessInfoViewController : BaseRegistrationViewController <UITextViewDelegate>

- (id) initWithBusinessName:(NSString *)bussName merchantKey:(long)mKey phone:(NSString *)phone;

@end
