//
//  AddTaxViewController.h
//  PSA
//
//  Created by Michael Simone on 8/2/09.
//  Copyright 2009 Dropped Pin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSAAppDelegate.h"

@interface AddTaxViewController : UIViewController {
	IBOutlet UITextField *taxRate1;
	IBOutlet UITextField *taxRate2;
	
	// Use the appDelegate for setting and getting values
	PSAAppDelegate *appDelegate;
}

@property (nonatomic, retain) PSAAppDelegate *appDelegate;
@property (nonatomic, retain) UITextField *taxRate1;
@property (nonatomic, retain) UITextField *taxRate2;

- (IBAction)back:(id)sender;
- (IBAction)save:(id)sender;

@end
