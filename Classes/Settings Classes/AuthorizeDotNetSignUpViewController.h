//
//  AuthorizeDotNetSignUpViewController.h
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthorizeDotNetSignUpViewController : UIViewController {
	UIWebView	*webView;
}

@property (nonatomic, retain) IBOutlet UIWebView	*webView;

- (IBAction) close:(id)sender;


@end
