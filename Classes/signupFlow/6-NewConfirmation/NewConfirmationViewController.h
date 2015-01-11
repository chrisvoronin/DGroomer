//
//  NewConfirmationViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewConfirmationViewController : UIViewController{
    IBOutlet UILabel *lblCall;
}

- (IBAction)onDone:(id)sender;
- (IBAction)onBack:(id)sender;
@end
