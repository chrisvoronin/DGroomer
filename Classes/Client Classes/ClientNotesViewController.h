//
//  ClientNotesViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GenericClientDetailViewController.h"
#import <UIKit/UIKit.h>


@interface ClientNotesViewController : GenericClientDetailViewController <UITextViewDelegate> {
	IBOutlet UITextView			*textView;
	IBOutlet UIImageView		*notesBackground;
	IBOutlet UIBarButtonItem	*bbiSave;
}

@property (nonatomic, retain) UIBarButtonItem	*bbiSave;
@property (nonatomic, retain) UITextView		*textView;
@property (nonatomic, retain) UIImageView		*notesBackground;

- (IBAction) bbiSaveTouchUp;
@end
