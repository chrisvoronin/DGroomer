//
//  PSAAppDelegate.h
//  myBusiness
//
//  Created by David J. Maier on 6/8/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import <AddressBook/AddressBook.h> 
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>


@class Client;

@interface PSAAppDelegate : NSObject 
<MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIApplicationDelegate, ABPersonViewControllerDelegate> 
{
	UIView		*activityIndicatorView;
    UIWindow	*window;
	// Navigation
	UINavigationController	*navigationController;
	// Client tabbing
	UITabBarController *clientTabBarController;
	// Opaque reference to the SQLite database.
	sqlite3 *database;
    BOOL firstRun;
}

// Good Properties (verified by Dave)
@property (nonatomic, retain) IBOutlet UIWindow					*window;
@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController		*clientTabBarController;

- (void) hideActivityIndicator;
- (void) showActivityIndicator;

- (void) swapClientTabWithNavigation;
- (void) swapNavigationForClientTabWithClient:(Client*)theClient;
- (void) swapNavigationForClientTabWithClient:(Client*)theClient swapContacts:(BOOL)isSwapping;
- (void) swapRecoveryViewWithClient:(Client*)theClient;

@end

