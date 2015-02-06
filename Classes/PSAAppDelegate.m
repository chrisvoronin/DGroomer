//
//  PSAAppDelegate.m
//  myBusiness
//
//  Created by David J. Maier on 6/8/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "Client.h"
#import "ClientProjectsViewController.h"
#import "ClientRecoveryViewController.h"
#import "ClientSwapViewController.h"
#import "ClientTableViewController.h"
#import "ClientTransactionsViewController.h"
#import "ClientNotesViewController.h"
#import "ClientServicesViewController.h"
#import	"GenericClientDetailViewController.h"
#import "PSADataManager.h"
#import "PSAAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "FirstViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "DataRegister.h"

@implementation PSAAppDelegate

@synthesize window;
@synthesize clientTabBarController, navigationController;

- (void)dealloc {
	[navigationController release];
	[clientTabBarController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Delegate Methods
#pragma mark -
/*
 *	For the shouldPerformDefaultActionForPerson: method
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch ( buttonIndex ) {
		case 0: {
			// Call
			NSString *urlString = [[NSString alloc] initWithFormat:@"tel://%@", actionSheet.title];
			NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[[UIApplication sharedApplication] openURL:url];
			[urlString release];
			[url release];
			break;
		}
		case 1: {
			// MMS
			NSString *urlString = [[NSString alloc] initWithFormat:@"sms://%@", actionSheet.title];
			NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[[UIApplication sharedApplication] openURL:url];
			[urlString release];
			[url release];
			break;
		}
	}
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	if( [self.navigationController.visibleViewController.view isDescendantOfView:self.window] ) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self.clientTabBarController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (BOOL) personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	if( property == kABPersonEmailProperty ) {
		if( [MFMailComposeViewController canSendMail] ) {
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			//picker.navigationBar.tintColor = [UIColor blackColor];
			picker.mailComposeDelegate = self;
			// Set up the recipients
			ABMultiValueRef multiValue = ABRecordCopyValue( person, property );
			CFIndex indexOfIdentifier = ABMultiValueGetIndexForIdentifier( multiValue, identifierForValue );
			CFStringRef email = ABMultiValueCopyValueAtIndex( multiValue, indexOfIdentifier );
			NSArray *toRecipients = [NSArray arrayWithObjects:(NSString*)email, nil]; 
			[picker setToRecipients:toRecipients];
			if( multiValue )	CFRelease( multiValue );
			if( email )			CFRelease( email );
			// Present the mail composition interface on the current viewController
			if( [self.navigationController.visibleViewController.view isDescendantOfView:self.window] ) {
				[self.navigationController presentViewController:picker animated:YES completion:nil];
			} else {
				[self.clientTabBarController presentViewController:picker animated:YES completion:nil];
			}
			[picker release];
		} else {
			NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not setup to send email. This is not a %@ setting, you must create an email account on your iPhone or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[msg release];
			[alert show];	
			[alert release];
		}
		return NO;
	} else if( property == kABPersonPhoneProperty ) {
		if( [[[UIDevice currentDevice] model] hasPrefix:@"iPhone"] ) {
			// Get phone number
			NSString *phone = nil;
			if( person ) {
				ABMultiValueRef multiValue = ABRecordCopyValue( person, property );
				CFIndex index = ABMultiValueGetIndexForIdentifier( multiValue, identifierForValue );
				CFStringRef number = ABMultiValueCopyValueAtIndex(multiValue, index); 
				phone = [[NSString alloc] initWithString:(NSString*)number]; 
				CFRelease(number);
				if( multiValue )	CFRelease(multiValue);
			}
			// Show Action Sheet
			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:phone delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"MMS", nil];
			[sheet showInView:window];
			[sheet release];
			[phone release];
			return NO;
		}
	}
	return YES;
}


#pragma mark -
#pragma mark Loading/Unloading of Client tabs view
#pragma mark -

- (void) swapNavigationForClientTabWithClient:(Client*)theClient {
	[self swapNavigationForClientTabWithClient:theClient swapContacts:NO];
}

- (void) swapNavigationForClientTabWithClient:(Client*)theClient swapContacts:(BOOL)isSwapping {
	// Create the tab bar controller
	clientTabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
	// The view controllers for our tabs
	
	// Make the Client info/edit view -OR- the Client Recovery view
	UIViewController *personVC = nil;
	if( (theClient.clientID == 0 || [theClient getPerson]) && !isSwapping ) {
		personVC = [[ABPersonViewController alloc] init];
		((ABPersonViewController*)personVC).personViewDelegate = self;
		((ABPersonViewController*)personVC).addressBook = [[PSADataManager sharedInstance] addressBook];
		((ABPersonViewController*)personVC).displayedPerson = [theClient getPerson];
		if( ((ABPersonViewController*)personVC).displayedPerson ) {
			((ABPersonViewController*)personVC).allowsEditing = YES;
		} else {
			((ABPersonViewController*)personVC).allowsEditing = NO;
		}
	} else {
		if( isSwapping ) {
			personVC = [[ClientSwapViewController alloc] initWithNibName:@"ClientSwapView" bundle:nil];
			((ClientSwapViewController*)personVC).client = theClient;
		} else {
			personVC = [[ClientRecoveryViewController alloc] initWithNibName:@"ClientRecoveryView" bundle:nil];
			((ClientRecoveryViewController*)personVC).client = theClient;
		}
	}
	
	// Set a tab bar item
	personVC.title = @"Client";
	UITabBarItem *personItem = [[UITabBarItem alloc] initWithTitle:@"Client" image:[UIImage imageNamed:@"iconClient.png"] tag:0];
	personVC.tabBarItem = personItem;
	[personItem release];
	
	// ABPersonViewController must be added directly to a navigation controller
	UINavigationController *detailsNav = [[UINavigationController alloc] initWithRootViewController:personVC];
	detailsNav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	// Make a custom back button
	UIBarButtonItem *bbiBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(swapClientTabWithNavigation)];
	// For some reason 3.2+ doesn't like the left bar button anymore
	if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 && [personVC isKindOfClass:[ABPersonViewController class]] ) {
		personVC.navigationItem.backBarButtonItem = bbiBack;
		personVC.navigationItem.hidesBackButton = NO;
		personVC.navigationItem.leftBarButtonItem = bbiBack;
	} else {
		// There is no cancel button when editing, however.
		personVC.navigationItem.leftBarButtonItem = bbiBack;
		//personVC.navigationItem.backBarButtonItem = nil;
	}
	[personVC release];
	// Formulas
#ifndef PROJECT_NOT_INCLUDED
	ClientProjectsViewController *pvc = [[ClientProjectsViewController alloc] initWithNibName:@"ClientProjectsView" bundle:nil];
	pvc.client = theClient;
	UINavigationController *projectsNav = [[UINavigationController alloc] initWithRootViewController:pvc];
	projectsNav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	pvc.navigationItem.leftBarButtonItem = bbiBack;
#endif
	// Services
	ClientServicesViewController *servicesVC = [[ClientServicesViewController alloc] initWithNibName:@"ClientServicesView" bundle:nil];
	servicesVC.client = theClient;
	UINavigationController *servicesNav = [[UINavigationController alloc] initWithRootViewController:servicesVC];
	servicesNav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	servicesVC.navigationItem.leftBarButtonItem = bbiBack;
	// Billing History
	ClientTransactionsViewController *history = [[ClientTransactionsViewController alloc] initWithNibName:@"ClientTransactionsView" bundle:nil];
	history.client = theClient;
	UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController:history];
	historyNav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	history.navigationItem.leftBarButtonItem = bbiBack;
	// Notes
	ClientNotesViewController *notes = [[ClientNotesViewController alloc] initWithNibName:@"ClientNotesView" bundle:nil];
	notes.client = theClient;
    UINavigationController *notesNav = [[UINavigationController alloc] initWithRootViewController:notes];
    notesNav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    notes.navigationItem.leftBarButtonItem = bbiBack;
#ifdef PROJECT_NOT_INCLUDED
	NSArray *viewControllers = [[NSArray alloc] initWithObjects:detailsNav, servicesNav, historyNav, notesNav, nil];
#else
	NSArray *viewControllers = [[NSArray alloc] initWithObjects:detailsNav, servicesNav, projectsNav, historyNav, notesNav, nil];
#endif
	clientTabBarController.viewControllers = viewControllers;
	[viewControllers release];
	[bbiBack release];
	[detailsNav release];
#ifndef PROJECT_NOT_INCLUDED
	[pvc release];
	[projectsNav release];
#endif
	[history release];
	[notes release];
	[servicesVC release];
	[servicesNav release];

	// Change the ABPersonViewController's backgrounds
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGold.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	personVC.view.backgroundColor = bgColor;
	if( [personVC isKindOfClass:[ABPersonViewController class]] ) {
		for( UIView *sub in personVC.view.subviews ) {
			sub.backgroundColor = bgColor;
		}
	}
	[bgColor release];

	// Animate the appearance of adding the tabbed view
	[window setUserInteractionEnabled:NO];
	// Remove QuartzCore framework and #import if you take this (and the method below) out
	CATransition *transition = [CATransition animation];
	transition.duration = 0.3;
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromRight;
	[window.layer addAnimation:transition forKey:nil];
	[navigationController.view removeFromSuperview];
	[window addSubview:clientTabBarController.view];
	[window setUserInteractionEnabled:YES];
}

- (void) swapClientTabWithNavigation {
	// Changed 2/2010: Check the name of the person versus our client name, saving if different.
	Client *client = nil;
	for( UIViewController *tmp in clientTabBarController.viewControllers ) {
		if( [tmp isKindOfClass:[GenericClientDetailViewController class]] ) {
			client = ((GenericClientDetailViewController*)tmp).client;
			break;
		}
	}
	if( (client.firstName && ![client.firstName isEqualToString:[client getFirstName]]) || (client.lastName && ![client.lastName isEqualToString:[client getLastName]]) ) {
		[client updateClientNameFromContact];
		[[PSADataManager sharedInstance] updateClient:client];
	}

	// Animate the appearance of adding the tabbed view
	[window setUserInteractionEnabled:NO];
	// Remove QuartzCore framework and #import if you take this (and the method above) out
	CATransition *transition = [CATransition animation];
	transition.duration = 0.3;
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromLeft;
	[window.layer addAnimation:transition forKey:nil];
	[clientTabBarController.view removeFromSuperview];
	[window addSubview:navigationController.view];
	[window setUserInteractionEnabled:YES];
	// Unload some objects (Client) from the ViewControllers
	for( UIViewController *cont in clientTabBarController.viewControllers ){
		if( [cont isKindOfClass:[UINavigationController class]] ) {
			for( UIViewController *cont2 in ((UINavigationController*)cont).viewControllers ){
				[cont2 viewDidUnload];
			}
		}
		[cont viewDidUnload];
	}
	[clientTabBarController release];
}

- (void) swapRecoveryViewWithClient:(Client*)theClient {
	
	if( theClient.clientID == 0 || [theClient getPerson] ) {
		ABPersonViewController *personVC = [[ABPersonViewController alloc] init];
		personVC.personViewDelegate = self;
		personVC.addressBook = [[PSADataManager sharedInstance] addressBook];
		personVC.displayedPerson = [theClient getPerson];
		if( personVC.displayedPerson ) {
			personVC.allowsEditing = YES;
		} else {
			personVC.allowsEditing = NO;
		}

		// Make a custom back button
		UIBarButtonItem *bbiBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(swapClientTabWithNavigation)];
		// For some reason 3.2+ doesn't like the left bar button anymore
		if( [[UIDevice currentDevice].systemVersion doubleValue] >= 3.2 ) {
			personVC.navigationItem.backBarButtonItem = bbiBack;
			personVC.navigationItem.leftBarButtonItem = nil;
		} else {
			// There is no cancel button when editing, however.
			personVC.navigationItem.leftBarButtonItem = bbiBack;
			//personVC.navigationItem.backBarButtonItem = nil;
		}
		[bbiBack release];
		
		// Set a tab bar item
		personVC.title = @"Client";
		UITabBarItem *personItem = [[UITabBarItem alloc] initWithTitle:@"Client" image:[UIImage imageNamed:@"iconClient.png"] tag:0];
		personVC.tabBarItem = personItem;
		[personItem release];
		
		// Change the ABPersonViewController's backgrounds
		UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGold.png"];
		UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
		personVC.view.backgroundColor = bgColor;
		for( UIView *sub in personVC.view.subviews ) {
			sub.backgroundColor = bgColor;
		}
		[bgColor release];
		
		// Unload some stuff
		for( UIViewController *cont2 in ((UINavigationController*)[clientTabBarController.viewControllers objectAtIndex:0]).viewControllers ){
			[cont2 viewDidUnload];
			[cont2.view removeFromSuperview];
		}
		
		NSArray *vcs = [[NSArray alloc] initWithObjects:personVC, nil];
		[(UINavigationController*)[clientTabBarController.viewControllers objectAtIndex:0] setViewControllers:vcs animated:NO];
		[vcs release];
		
		[personVC release];
	}
	 
}

#pragma mark -
#pragma mark ActivityIndicator Methods
#pragma mark -
- (void) hideActivityIndicator {
	if( activityIndicatorView ) {
		[activityIndicatorView removeFromSuperview];
		[activityIndicatorView release];
		activityIndicatorView = nil;
	}
}

- (void) showActivityIndicator {
	if( !activityIndicatorView ) {
		activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 568 )];
		activityIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
		UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		aiv.center = CGPointMake( 160, 284 );
		[aiv startAnimating];
		[activityIndicatorView addSubview:aiv];
		[aiv release];
		[window addSubview:activityIndicatorView];
	}
}



#pragma mark -
#pragma mark UIApplication Delegate Methods
#pragma mark -
/*
 *	applicationDidFinishLaunching:
 *	Called before the first view loads, do initial setup here.
 */
- (void) applicationDidFinishLaunching:(UIApplication *)application {
	// Check our Address Book
	[[PSADataManager sharedInstance] createAddressBookGroupIfNecessary];
	// Disable idle timer
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	// Make sure we have a writable copy of the database
    [[PSADataManager sharedInstance] loadDatabase];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"firstRun"]){
        //flag doesnt exist then this IS the first run
        self->firstRun = YES;
        
    }else{
        //flag does exist so this ISNT the first run
        self->firstRun = NO;
    }
    
    
    if (self->firstRun) {
        FirstViewController *viewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
        
        self.window.rootViewController = viewController;
    }
    else{
        // Add the navigation controller's current view as a subview of the window
        [self.window setRootViewController:navigationController]; // iOS 6 autorotation fix
    }
    
    //[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
    
    
    
    /**/
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] - 1;
}

/*- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSDate *alertTime = [NSDate dateWithTimeIntervalSinceNow:5];
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
                                        init];
    if (notifyAlarm)
    {
        notifyAlarm.fireDate = alertTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        notifyAlarm.soundName = @"bell_tree.mp3";
        notifyAlarm.alertBody = @"Staff meeting in 30 minutes";
        [app scheduleLocalNotification:notifyAlarm];
    }
}*/
/*
 *	applicationWillTerminate:
 *	Called before the app closes
 */
- (void) applicationWillTerminate:(UIApplication *)application {
	// Save and close the database
    [[PSADataManager sharedInstance] prepareForExit];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSettings setDefaultAppID:@"421132574681288"];
    [FBAppEvents activateApp];

}


@end
