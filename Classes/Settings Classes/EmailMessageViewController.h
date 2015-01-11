//
//  EmailMessageViewController.h
//  myBusiness
//
//  Created by David J. Maier on 2/25/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Email;

@interface EmailMessageViewController : PSABaseViewController <UIActionSheetDelegate> {
	Email			*email;
	UIButton		*btnInsertField;
	UISwitch		*swBccSelf;
	UIScrollView	*scrollView;
	UITextField		*txtSubject;
	UITextView		*txtMessage;
}

@property (nonatomic, retain) Email					*email;
@property (nonatomic, retain) IBOutlet UIButton		*btnInsertField;
@property (nonatomic, retain) IBOutlet UIScrollView	*scrollView;
@property (nonatomic, retain) IBOutlet UISwitch		*swBccSelf;
@property (nonatomic, retain) IBOutlet UITextField	*txtSubject;
@property (nonatomic, retain) IBOutlet UITextView	*txtMessage;

- (IBAction)	btnInsertFieldTouchUp:(id)sender;
- (void)		save;

@end
