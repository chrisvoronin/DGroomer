//
//  ColorPickerViewController.h
//  myBusiness
//
//  Created by David J. Maier on 11/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSABaseViewController.h"

@class Service;

@interface ColorPickerViewController : PSABaseViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	Service					*service;
	NSArray					*colors;
    
}
@property (retain, nonatomic) IBOutlet UIView *m_buttonContainer;
@property (readwrite, nonatomic) NSString *m_colorSelected;
@property (nonatomic, retain) Service		*service;
@property (nonatomic, retain) UIPickerView	*picker;

- (void) done;

@end
