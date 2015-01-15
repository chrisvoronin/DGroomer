//
//  PSAAboutViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "PSAAboutViewController.h"


@implementation PSAAboutViewController

@synthesize flipDelegate, lbVersion;


- (void) viewDidLoad {
    self.title = @"CONTACT";
	//
	NSString *text = [[NSString alloc] initWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	lbVersion.text = text;
	[text release];
	//
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void) dealloc {
	self.lbVersion = nil;
    [super dealloc];
}


- (IBAction) contactSupport:(id)sender {
	
    NSString *email = [[NSString alloc] initWithFormat:@"mailto:%@?subject=%@%@Support%@Ticket", @"support@merchantaccountsolutions.com", [APPLICATION_NAME stringByReplacingOccurrencesOfString:@" " withString:@"%20"], @"%20", @"%20"];
	//DebugLog(@"%@", email );
	NSURL *url = [[NSURL alloc] initWithString:email];
	[email release];
	[[UIApplication sharedApplication] openURL:url];
	[url release];
    return;    
    
#ifdef CONTRACTOR
	NSString *addr = [[NSString alloc] initWithString:@"contractor@mybusinessapp.net"];
#elif ELECTRICIAN
	NSString *addr = [[NSString alloc] initWithString:@"electrician@mybusinessapp.net"];
#elif GROOMER
	NSString *addr = [[NSString alloc] initWithString:@"groomer@mybusinessapp.net"];
#elif LAWN
	NSString *addr = [[NSString alloc] initWithString:@"landscaper@mybusinessapp.net"];
#elif LOCKSMITH
	NSString *addr = [[NSString alloc] initWithString:@"locksmith@mybusinessapp.net"];
#elif MASSAGE
	NSString *addr = [[NSString alloc] initWithString:@"massage@mybusinessapp.net"];
#elif NAIL
	NSString *addr = [[NSString alloc] initWithString:@"nails@mybusinessapp.net"];
#elif PHOTOGRAPHER
	NSString *addr = [[NSString alloc] initWithString:@"photographer@mybusinessapp.net"];
#elif PLUMBER
	NSString *addr = [[NSString alloc] initWithString:@"plumber@mybusinessapp.net"];
#elif TRAINER
	NSString *addr = [[NSString alloc] initWithString:@"trainer@mybusinessapp.net"];
#else
	NSString *addr = [[NSString alloc] initWithString:@"support@mybusinessapp.net"];
#endif
	
//	NSString *email = [[NSString alloc] initWithFormat:@"mailto:%@?subject=%@%@Support%@Ticket", addr, [APPLICATION_NAME stringByReplacingOccurrencesOfString:@" " withString:@"%20"], @"%20", @"%20"];
//	//DebugLog(@"%@", email );
//	[addr release];
//	NSURL *url = [[NSURL alloc] initWithString:email];
//	[email release];
//	[[UIApplication sharedApplication] openURL:url];877-976-8218
//	[url release];
}


- (IBAction) done:(id)sender {
	[self.flipDelegate toggleView:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10){
        if(buttonIndex == 1){
            NSString *URLString = @"tel://877-976-8218";
            NSURL *URL = [NSURL URLWithString:URLString];
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
    
}
- (IBAction) goToWebsite:(id)sender{
    
    UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:nil message:@"877-976-8218" delegate:self
                                             cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertview.tag = 10;
    [alertview show];
    return;
	
//#ifdef CONTRACTOR
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/contractor"];
//#elif ELECTRICIAN
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/electrician"];
//#elif GROOMER
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/doggroomer"];
//#elif LAWN
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/landscaper"];
//#elif LOCKSMITH
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/locksmith"];
//#elif MASSAGE
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/massage"];
//#elif NAIL
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/nails"];
//#elif PHOTOGRAPHER
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/photographer"];
//#elif PLUMBER
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/plumber"];
//#elif TRAINER
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net/trainer"];
//#else
//	NSURL *url = [[NSURL alloc] initWithString:@"http://www.mybusinessapp.net"];
//#endif
//
//	[[UIApplication sharedApplication] openURL:url];
//	[url release];
}

@end
