//
//  PSAReminderViewController.h
//  iBiz
//
//  Created by johnny on 2/14/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRegistrationViewController.h"

@protocol PSAReminderViewDelegate
@end

@interface PSAReminderViewController : BaseRegistrationViewController{
    MBProgressHUD *progress;
}

@property (nonatomic, assign) id<PSAReminderViewDelegate> delegate;
@property (nonatomic, retain) NSString		*strTextTo;
@property (nonatomic, retain) NSString		*strEmailTo;
@property (nonatomic, retain) NSString		*strEmailContent;
@property (nonatomic, retain) NSString		*strEmailSubject;
@property (nonatomic, assign) int          isEmail;
@end
