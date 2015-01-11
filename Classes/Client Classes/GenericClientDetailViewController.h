//
//  GenericClientDetailViewController.h
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Client;

@interface GenericClientDetailViewController : UIViewController {
	Client	*client;
	IBOutlet UIBarButtonItem *bbiBack;
}

@property (nonatomic, retain) UIBarButtonItem	*bbiBack;
@property (nonatomic, retain) Client *client;

- (IBAction) goBackToClients;

@end
