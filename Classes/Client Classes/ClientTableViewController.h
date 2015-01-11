//
//  ClientViewController.h
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "PSADataManager.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class Client;

// Protocol Definition
@protocol PSAClientTableDelegate <NSObject>
@required
- (void) selectionMadeWithClient:(Client*)theClient;
@end

@interface ClientTableViewController : UIViewController 
<MFMailComposeViewControllerDelegate, PSAClientTableDelegate, PSADataManagerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>  {
	IBOutlet UITableView		*clientTable;
	IBOutlet UISegmentedControl	*segActive;
	IBOutlet UISegmentedControl	*segDisplay;
	NSDictionary				*clients;
	NSArray						*sortedKeys;
	NSIndexPath					*clientToDelete;
	id							clientDelegate;
	// Search
	NSMutableArray				*filteredList;
	UITableView					*tableDeleting;
	// Passed in to hide segDisplay
	BOOL						showBirthdayAnniversarySegment;
	// Swapping Client Contacts
	BOOL						isSwappingContacts;
}

@property (nonatomic, retain) NSDictionary					*clients;
@property (nonatomic, retain) UITableView					*clientTable;
@property (nonatomic, assign) BOOL							isSwappingContacts;
@property (nonatomic, retain) UISegmentedControl			*segActive;
@property (nonatomic, retain) UISegmentedControl			*segDisplay;
@property (nonatomic, assign) id <PSAClientTableDelegate>	clientDelegate;
@property (nonatomic, assign) BOOL							showBirthdayAnniversarySegment;

- (IBAction)	btnAddTouchUp:(id)sender;
- (void)		checkForMissingPersons;
- (void)		emailBirthdayOrAnniversary:(id)sender;
- (void)		releaseAndRepopulateClients;
- (IBAction)	segActiveValueChanged:(id)sender;
- (IBAction )	segDisplayValueChanged:(id)sender;
- (void)		sendAnniversaryEmailWithClient:(Client*)theClient;
- (void)		sendBirthdayEmailWithClient:(Client*)theClient;

@end
