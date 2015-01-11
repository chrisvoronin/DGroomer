    //
//  AuthorizeDotNetSignUpViewController.m
//  PSA
//
//  Created by David J. Maier on 5/4/10.
//  Copyright 2010 SalonTechnologies, Inc. All rights reserved.
//

#import "AuthorizeDotNetSignUpViewController.h"


@implementation AuthorizeDotNetSignUpViewController

@synthesize webView;

- (void) viewDidAppear:(BOOL)animated {
	NSURL *url = [[NSURL alloc] initWithString:@"http://www.netpaybankcard.com/admin/onlineapplication.php?mid=32"];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
	[webView loadRequest:urlRequest];
	[url release];
	[urlRequest release];
}

- (void) viewWillDisappear:(BOOL)animated {
	if( webView.loading ) {
		[webView stopLoading];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.webView = nil;
    [super dealloc];
}

- (IBAction) close:(id)sender {
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
