//
//  NewPrincipalInfoViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewAccountInfoViewController.h"
#import "AddressModel.h"
#import "BaseRegistrationViewController.h"

@interface NewPrincipalInfoViewController : BaseRegistrationViewController
-(id)initWithAddress:(NSString*)bAddress city:(NSString*)bCity state:(NSString*)bState zip:(NSString*)bZip merchantKey:(long)mKey;
@end
