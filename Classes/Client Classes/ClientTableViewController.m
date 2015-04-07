//
//  ClientViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/5/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//
#import "AddClientContactController.h"
#import "Client.h"
#import "Company.h"
#import "Email.h"
#import "PSAAppDelegate.h"
#import "ClientTableViewController.h"
#import "PSAReminderViewController.h"

@implementation ClientTableViewController

@synthesize clients, clientDelegate, clientTable, isSwappingContacts, segActive, segDisplay, showBirthdayAnniversarySegment;

#pragma mark -
#pragma mark ViewController Methods
#pragma mark -

- (void) viewDidLoad {
	if( clientDelegate == nil ) {
		self.clientDelegate = self;
	}
	clientToDelete = nil;
	// Set the navigation bar title
	if( isSwappingContacts ) {
		//self.title = @"SWAP CONTACTS";
        self.title = @"CLIENTS";
        UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnAddTouchUp:)];
        self.navigationItem.rightBarButtonItem = btnAdd;
        [btnAdd release];
	} else {
		self.title = @"CLIENTS";
		// Add "+" Button
		UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnAddTouchUp:)];
		self.navigationItem.rightBarButtonItem = btnAdd;
		[btnAdd release];
	}
	// Show or hide
	if( !showBirthdayAnniversarySegment ) {
		segDisplay.hidden = YES;
	}
	//
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void) viewDidAppear:(BOOL)animated {
	// Fill our local dictionary with clients, need to release
	// Only refresh if there are no clients, or not showing bday/anniversary
	//if( segDisplay.selectedSegmentIndex == 0 || clients == nil ) {
		[self releaseAndRepopulateClients];
	//}
}

- (void) viewDidDisappear:(BOOL)animated {
	// Delete the Client array?
	[clients release];
	clients = nil;
	[sortedKeys release];
	sortedKeys = nil;
	[filteredList release];
	filteredList = nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[filteredList release];
	self.segDisplay = nil;
	self.segActive = nil;
	self.clientTable = nil;
	[clientToDelete release];
	[sortedKeys release];
	[clients release];
    [super dealloc];
}

- (void) releaseAndRepopulateClients {
	[self.segDisplay setUserInteractionEnabled:NO];
	[self.segActive setUserInteractionEnabled:NO];
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	//
	[[PSADataManager sharedInstance] setDelegate:self];
	if( segActive.selectedSegmentIndex == 0 ) {
		// Active
		[[PSADataManager sharedInstance] getClientsWithActiveFlag:YES];
	} else if( segActive.selectedSegmentIndex == 1 ) {
		// All
		[[PSADataManager sharedInstance] getClientsWithActiveFlag:NO];
	}
}

- (void) checkForMissingPersons {
	if( [PSADataManager sharedInstance].askAboutRecoveringClients ) {
		BOOL breakOut = NO;
		for( NSArray *tmp in [clients allValues] ) {
			if( (NSNull*)tmp != [NSNull null] ) {
				for( Client *tmpClient in tmp ) {
					if( tmpClient.clientID > 0 && ![tmpClient getPerson] ) {
						// Show the ActionSheet
						NSString *thisTitle = [[NSString alloc] initWithFormat:@"One or more of your clients are missing their contact in your device's address book.\n\nWould you like %@ to try and recover them automatically?", APPLICATION_NAME];
						UIActionSheet *query = [[UIActionSheet alloc] initWithTitle:thisTitle delegate:self cancelButtonTitle:@"Don't Recover" destructiveButtonTitle:nil otherButtonTitles:@"Attempt Recovery", nil];
						[thisTitle release];
						[query showInView:self.view];
						[query release];
						// Break out of all looping
						breakOut = YES;
						break;
					}
				}
			}
			if( breakOut ) {
				// Get out of this loop too!
				break;
			}
		}
	}
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark myBusiness Delegate Methods
#pragma mark -
/*
 *
 */
- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	if( clients )		[clients release];
	if( sortedKeys )	[sortedKeys release];
	// Determine the dictionary to load based on the segDisplay control
	if( segDisplay.selectedSegmentIndex == 0 ) {
		self.title = @"CLIENTS";
		clients = [[PSADataManager sharedInstance] getClientsDictionaryWithArray:theArray];
		sortedKeys = [[[clients allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
		[self checkForMissingPersons];
	} else if( segDisplay.selectedSegmentIndex == 1 ) {
		self.title = @"BIRTHDAY";
		clients = [[PSADataManager sharedInstance] getClientsDictionaryWithArray:theArray isBirthday:YES];
		sortedKeys = [[NSArray alloc] initWithObjects:@"Today", @"Tomorrow", @"Next 7 Days", nil];
	} else if( segDisplay.selectedSegmentIndex == 2 ) {
		self.title = @"ANNIVERSARIES";
		clients = [[PSADataManager sharedInstance] getClientsDictionaryWithArray:theArray isBirthday:NO];
		sortedKeys = [[NSArray alloc] initWithObjects:@"Today", @"Tomorrow", @"Next 7 Days", nil];
	}
	// Create a search bar list of all the client objects
	if( filteredList )	[filteredList release];
	filteredList = [[NSMutableArray alloc] init];
	[clientTable reloadData];
	[self.searchDisplayController.searchResultsTableView reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
	[self.segActive setUserInteractionEnabled:YES];
	[self.segDisplay setUserInteractionEnabled:YES];
}

/*
 *	When this class is responding to it's own delegate, go to the ClientView.
 */
- (void) selectionMadeWithClient:(Client*)theClient {	
	if( isSwappingContacts ) {
		[(PSAAppDelegate *)[[UIApplication sharedApplication] delegate] swapNavigationForClientTabWithClient:theClient swapContacts:YES];
	} else {
		[(PSAAppDelegate *)[[UIApplication sharedApplication] delegate] swapNavigationForClientTabWithClient:theClient];
	}
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -

/*
 *	Receives notification of which button was pressed on the alert view.
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag==1001)
    {
        if(buttonIndex==3)
        {
            return;
        }
        
        PSAReminderViewController *cont = [[PSAReminderViewController alloc] initWithNibName:@"PSAReminderViewController" bundle:nil];
        
        Email *email = [[PSADataManager sharedInstance] getBirthdayEmail];
        
        NSString *clientEmail = [selectedClient getEmailAddressHome];
        if( clientEmail == nil ) {
            clientEmail = [selectedClient getEmailAddressWork];
            if( clientEmail == nil ) {
                clientEmail = [selectedClient getEmailAddressAny];
            }
        }
        
        if(clientEmail==nil){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Receipt!" message:@"This client doesn't have email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        NSString *message = email.message;
        message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[selectedClient getClientNameFirstThenLast]];
        NSDate *bDate = [selectedClient getBirthdate];
        message = [message stringByReplacingOccurrencesOfString:@"<<BIRTHDATE>>" withString:[[PSADataManager sharedInstance] getStringForDate:bDate withFormat:NSDateFormatterLongStyle]];
        [bDate release];
        
        
        
        NSString *strPhone = [selectedClient getPhoneCell];
        if(strPhone.length<1)
        {
            strPhone = [selectedClient getPhoneHome];
            if(strPhone.length<1) {
                strPhone = [selectedClient getPhoneWork];
            }
        }
        if(strPhone.length<1 && (int)buttonIndex>=1){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Text Receipt!" message:@"This client doesn't have phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        NSString *subject = email.subject;
        //[email release];
        cont.strEmailTo = clientEmail;
        cont.strEmailContent = message;
        cont.strEmailSubject = subject;
        cont.strTextTo = strPhone;
        cont.isEmail = (int)buttonIndex;
        [self.navigationController pushViewController:cont animated:YES];
        [cont release];
        return;
    }
    
    if(actionSheet.tag==1002)
    {
        if(buttonIndex==3)
        {
            return;
        }
        
        PSAReminderViewController *cont = [[PSAReminderViewController alloc] initWithNibName:@"PSAReminderViewController" bundle:nil];
        
        Email *email = [[PSADataManager sharedInstance] getAnniversaryEmail];
        
        NSString *clientEmail = [selectedClient getEmailAddressHome];
        if( clientEmail == nil ) {
            clientEmail = [selectedClient getEmailAddressWork];
            if( clientEmail == nil ) {
                clientEmail = [selectedClient getEmailAddressAny];
            }
        }
        
        
        NSString *message = email.message;
        message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[selectedClient getClientNameFirstThenLast]];
        NSDate *bDate = [selectedClient getAnniversaryDate];
        message = [message stringByReplacingOccurrencesOfString:@"<<ANNIVERSARY>>" withString:[[PSADataManager sharedInstance] getStringForDate:bDate withFormat:NSDateFormatterLongStyle]];
        [bDate release];
        
        
        
        NSString *strPhone = [selectedClient getPhoneCell];
        if(strPhone.length<1)
        {
            strPhone = [selectedClient getPhoneHome];
            if(strPhone.length<1) {
                strPhone = [selectedClient getPhoneWork];
            }
        }
        
        NSString *subject = email.subject;
        //[email release];
        cont.strEmailTo = clientEmail;
        cont.strEmailContent = message;
        cont.strEmailSubject = subject;
        cont.strTextTo = strPhone;
        cont.isEmail = (int)buttonIndex;
        [self.navigationController pushViewController:cont animated:YES];
        [cont release];
        return;
    }
    
	if( [actionSheet.title hasPrefix:@"This will delete"] ) {
		// Clicked the Delete button
		if( buttonIndex == 0 ) {
			if( clientToDelete != nil ) {
				// Get the client we're deleting
				NSArray *clientArray = nil;
				if( tableDeleting == self.searchDisplayController.searchResultsTableView ) {
					clientArray = filteredList;
				} else {
					clientArray = [clients objectForKey:[sortedKeys objectAtIndex:clientToDelete.section]];
				}
				//
				if( (NSNull*)clientArray != [NSNull null] ) {
					Client *client = [clientArray objectAtIndex:clientToDelete.row];
					// Delete it from the DB and PSADataManager.clients array
					[[PSADataManager sharedInstance] removeClient:client];
				}
				clientArray = nil;
				// Release and repopulate our dictionary
				[self releaseAndRepopulateClients];
			}		
		}
		tableDeleting = nil;
		[clientToDelete release];
		clientToDelete = nil;
	} else {
		// Client Recovery
		if( buttonIndex == 0 ) {
			[[PSADataManager sharedInstance] attemptRecoveryForAllClients:clients];
			[clientTable reloadData];
		} else {
			[PSADataManager sharedInstance].askAboutRecoveringClients = NO;
		}
	}
    
}

#pragma mark -
#pragma mark Control Action Methods
#pragma mark -
/*
 *	btnAddTouchUp:
 *	Pushes the view to add a client onto the navigation stack
 */
- (IBAction) btnAddTouchUp:(id)sender {
	AddClientContactController *addController = [[AddClientContactController alloc] initWithNibName:@"AddClientContact" bundle:nil];
	[self.navigationController pushViewController:addController animated:YES];
	[addController release];
}

/*
 *
 */
- (void) emailBirthdayOrAnniversary:(id)sender {	
	if( [[sender superview] isKindOfClass:[UITableViewCell class]] ) {
		UITableViewCell *sendingCell = (UITableViewCell*)[sender superview];
        
        id view = [sendingCell superview];
        
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        
        UITableView *sendingTable = (UITableView *)view;
        
		//if( [[sendingCell superview] isKindOfClass:[UITableView class]] ) {
			//UITableView *sendingTable = (UITableView*)[[sender superview] superview];
			NSIndexPath *indexPath = [sendingTable indexPathForCell:sendingCell];
			NSArray *clientArray = nil;
			if( sendingTable == self.searchDisplayController.searchResultsTableView ) {
				clientArray = filteredList;
			} else {
				clientArray = [clients objectForKey:[sortedKeys objectAtIndex:indexPath.section]];
			}
			//
			if( clientArray && (NSNull*)clientArray != [NSNull null] ) {
				Client *client = [clientArray objectAtIndex:indexPath.row];
				if( client != nil ) {
					if( segDisplay.selectedSegmentIndex == 1 ) {
						[self sendBirthdayEmailWithClient:client];
					} else {
						[self sendAnniversaryEmailWithClient:client];
					}
				}
			}
		//}
	}
}

/*
 *
 */
- (void) sendAnniversaryEmailWithClient:(Client*)theClient {
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Do you want to send a reminder?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Text", @"Both", nil];
    alert.tag = 1002;
    self->selectedClient = theClient;
    [alert showInView:self.view];
    [alert release];
    return;
    // Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		Email *email = [[PSADataManager sharedInstance] getAnniversaryEmail];
		
		NSString *clientEmail = [theClient getEmailAddressHome];
		if( clientEmail == nil ) {
			clientEmail = [theClient getEmailAddressWork];
			if( clientEmail == nil ) {
				clientEmail = [theClient getEmailAddressAny];
			}
		}
		NSArray *to = [NSArray arrayWithObjects:clientEmail, nil]; 
		[picker setToRecipients:to];
		[clientEmail release];
		
		if( email.bccCompany ) {
			// Company Info
			Company *company = [[PSADataManager sharedInstance] getCompany];
			// Set up the recipients
			if( company.companyEmail ) {
				NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
				[picker setBccRecipients:bccRecipients];
			}
			[company release];
		}
		
		NSString *message = email.message;
		message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[theClient getClientNameFirstThenLast]];
		NSDate *annDate = [theClient getAnniversaryDate];
		message = [message stringByReplacingOccurrencesOfString:@"<<ANNIVERSARY>>" withString:[[PSADataManager sharedInstance] getStringForDate:annDate withFormat:NSDateFormatterLongStyle]];
		[annDate release];
		
		[picker setSubject:email.subject];
		[picker setMessageBody:message isHTML:NO];
		
		[email release];
		// Present the mail composition interface. 
		//[self presentViewController:picker animated:YES completion:nil];
        [self presentViewController:picker animated:YES completion:nil];
		[picker release];
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not ready to send email. This is not a %@ setting, you must create an email account on your iPhone, iPad, or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}

/*
 *
 */
- (void) sendBirthdayEmailWithClient:(Client*)theClient {
    
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"Do you want to send a reminder?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Text", @"Both", nil];
    alert.tag = 1001;
    self->selectedClient = theClient;
    [alert showInView:self.view];
    [alert release];
    return;
	// Open Email
	if( [MFMailComposeViewController canSendMail] ) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		//picker.navigationBar.tintColor = [UIColor blackColor];
		picker.mailComposeDelegate = self;
		
		Email *email = [[PSADataManager sharedInstance] getBirthdayEmail];
		
		NSString *clientEmail = [theClient getEmailAddressHome];
		if( clientEmail == nil ) {
			clientEmail = [theClient getEmailAddressWork];
			if( clientEmail == nil ) {
				clientEmail = [theClient getEmailAddressAny];
			}
		}
		NSArray *to = [NSArray arrayWithObjects:clientEmail, nil]; 
		[picker setToRecipients:to];
		[clientEmail release];
		
		if( email.bccCompany ) {
			// Company Info
			Company *company = [[PSADataManager sharedInstance] getCompany];
			// Set up the recipients
			if( company.companyEmail ) {
				NSArray *bccRecipients = [NSArray arrayWithObjects:company.companyEmail, nil]; 
				[picker setBccRecipients:bccRecipients];
			}
			[company release];
		}
		
		NSString *message = email.message;
		message = [message stringByReplacingOccurrencesOfString:@"<<CLIENT>>" withString:[theClient getClientNameFirstThenLast]];
		NSDate *bDate = [theClient getBirthdate];
		message = [message stringByReplacingOccurrencesOfString:@"<<BIRTHDATE>>" withString:[[PSADataManager sharedInstance] getStringForDate:bDate withFormat:NSDateFormatterLongStyle]];
		[bDate release];
		
		[picker setSubject:email.subject];
		[picker setMessageBody:message isHTML:NO];
		
		[email release];
		// Present the mail composition interface. 
		//[self presentViewController:picker animated:YES completion:nil];
        [self presentViewController:picker animated:YES completion:nil];
        
		[picker release];
		
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not ready to send email. This is not a %@ setting, you must create an email account on your iPhone, iPad, or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];	
		[alert release];
	}
}

/*
 *
 */
- (IBAction ) segDisplayValueChanged:(id)sender {
	[self releaseAndRepopulateClients];
}

/*
 *	segActiveValueChanged:
 *	Fetches the proper client list and reloads the table
 */
- (IBAction) segActiveValueChanged:(id)sender {
	[self releaseAndRepopulateClients];
}

#pragma mark -
#pragma mark TableView Methods
#pragma mark -
#pragma mark Cells
//
//	Creates or reuses a cell, sets it's values, and returns for display
//
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	if( segDisplay.selectedSegmentIndex == 0 ) {
		cell = [aTableView dequeueReusableCellWithIdentifier:@"ClientCell"];
	} else {
		cell = [aTableView dequeueReusableCellWithIdentifier:@"ClientBDayAnnCell"];
	}
	
    if( cell == nil && segDisplay.selectedSegmentIndex == 0 ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ClientCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if( clientDelegate == self ) {
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryType = UITableViewCellAccessoryNone;
		}
    } else if( cell == nil ) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ClientBDayAnnCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		// Set up a button to trigger the emailing
		UIButton *btnEmail = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		[btnEmail setImage:[UIImage imageNamed:@"btnCellEmailUp.png"] forState:UIControlStateNormal];
		[btnEmail setImage:[UIImage imageNamed:@"btnCellEmailDown.png"] forState:UIControlStateHighlighted];
		cell.accessoryView = btnEmail;
		[btnEmail release];
		
	}

	NSArray *clientArray = nil;
	if( aTableView == self.searchDisplayController.searchResultsTableView ) {
		clientArray = filteredList;
	} else {
		if( sortedKeys && sortedKeys.count > indexPath.section ) {
			NSString *key = [sortedKeys objectAtIndex:indexPath.section];
			if( clients && key ) {
				clientArray = [clients objectForKey:key];
			}
		}
	}
	
	// Changed: 2/9/2010... added "clientArray &&", and the if(client) checks
	if( clientArray && (NSNull*)clientArray != [NSNull null] ) {
		Client *client = [clientArray objectAtIndex:indexPath.row];
		if( client ) {
			cell.textLabel.text = [client getClientName];
			if( segDisplay.selectedSegmentIndex == 0 ) {
				// Phone #
				NSString *cellNum = [client getPhoneCell];
				NSString *home = [client getPhoneHome];
				NSString *work = [client getPhoneWork];
				NSString *otherPhone = [client getPhoneAny];
				if( cellNum != nil ) {
					cell.detailTextLabel.text = cellNum;
				} else if( home != nil ) {
					cell.detailTextLabel.text = home;
				} else if( work != nil ) {
					cell.detailTextLabel.text = work;
				} else if( otherPhone != nil ) {
					cell.detailTextLabel.text = otherPhone;
				} else {
					cell.detailTextLabel.text = @"";
				}
				[cellNum release];
				[home release];
				[work release];
				[otherPhone release];
			} else if( segDisplay.selectedSegmentIndex == 1 ) {
				[(UIButton*)cell.accessoryView addTarget:self action:@selector(emailBirthdayOrAnniversary:) forControlEvents:UIControlEventTouchUpInside];
				//
				NSDate *bday = [client getBirthdate];
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:bday withFormat:NSDateFormatterLongStyle];
				[bday release];
			} else if( segDisplay.selectedSegmentIndex == 2 ) {
				[(UIButton*)cell.accessoryView addTarget:self action:@selector(emailBirthdayOrAnniversary:) forControlEvents:UIControlEventTouchUpInside];
				//
				NSDate *ann = [client getAnniversaryDate];
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:ann withFormat:NSDateFormatterLongStyle];
				[ann release];
			} else {
				cell.detailTextLabel.text = @"";
			}
		} else {
			cell.textLabel.text = @"No Name";
			cell.detailTextLabel.text = @"";
		}
	}
		
	return cell;
}

//
//	Transitions to Client view for detail display/editing
//
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Which client is it?
	NSArray *clientArray;
	if( tableView == self.searchDisplayController.searchResultsTableView )	{
		clientArray = filteredList;
	} else {
		clientArray = [clients objectForKey:[sortedKeys objectAtIndex:indexPath.section]];
	}
	if( (NSNull*)clientArray != [NSNull null] ) {
		Client *client = [clientArray objectAtIndex:indexPath.row];
		if( client != nil ) {
			// Call this method for whoever cares about the selection
			[self.clientDelegate selectionMadeWithClient:client];
		}
	}
	
}

//
//	Returns the number of clients for each letter of the alphabet (section)
//
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if( aTableView == self.searchDisplayController.searchResultsTableView )	return filteredList.count;
	NSArray *clientArray = [clients objectForKey:[sortedKeys objectAtIndex:section]];
	if( (NSNull*)clientArray != [NSNull null] ) {
		return clientArray.count;
	}
	return 0;
}

//
//	Allows for the delete button when swiping a cell
//
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *clientArray;
	if( segDisplay.selectedSegmentIndex != 0 || isSwappingContacts ) {
		return UITableViewCellEditingStyleNone;
	}
	if( tableView == self.searchDisplayController.searchResultsTableView ) {
		clientArray = filteredList;
	} else {
		clientArray = [clients objectForKey:[sortedKeys objectAtIndex:indexPath.section]];
	}
	//
	if( (NSNull*)clientArray != [NSNull null] ) {
		Client *client = [clientArray objectAtIndex:indexPath.row];
		if( client != nil ) {
			// Client 0 is our Guest account, no delete allowed
			if( client.clientID == 0 ) {
				return UITableViewCellEditingStyleNone;
			}
		}
	}
	return UITableViewCellEditingStyleDelete;
}

//
//	Handles what to do when the editing delete button is pressed
//
- (void) tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Retain this so it doesn't disappear after the method exits
		clientToDelete = [indexPath retain];
		tableDeleting = tv;
		// Display alert
		NSString *thisTitle = [[NSString alloc] initWithFormat:@"This will delete the client from %@ but not from your device's address book.", APPLICATION_NAME];
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:thisTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[thisTitle release];
		[alert showInView:self.view];	
		[alert release];
    }
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	NSArray *clientArray = nil;
	if( tableView == self.searchDisplayController.searchResultsTableView ) {
		clientArray = filteredList;
	} else {
		if( sortedKeys && sortedKeys.count > indexPath.section ) {
			NSString *key = [sortedKeys objectAtIndex:indexPath.section];
			if( clients && key ) {
				clientArray = [clients objectForKey:key];
			}
		}
	}

	if( clientArray && (NSNull*)clientArray != [NSNull null] ) {
		Client *client = [clientArray objectAtIndex:indexPath.row];
		// If there is a client, it is not a guest, and doesn't have an ABPerson
		if( client && client.clientID != 0 && ![client getPerson] ) {
			cell.backgroundColor = [UIColor colorWithRed:1 green:.63 blue:.58 alpha:1];
		}
	}
}


#pragma mark Sections
//
//	The number of sections, based on the client dictionary keys (a-z, not shown if no clients with that letter)
//
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return 1;
	return [sortedKeys count];
}

//
//	The titles for each section index on the right hand column (letter of the alphabet)
//
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return nil;
	if( segDisplay.selectedSegmentIndex != 0 )	return nil;
	return sortedKeys;
}

//
//	When the right hand a-z index is pressed, jump to that index
//
- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return 0;
	if( segDisplay.selectedSegmentIndex != 0 )	return 0;
	return index;
}

//
//	The title to display for each section (a-z, based on client dictionary)
//
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if( tableView == self.searchDisplayController.searchResultsTableView )	return nil;
	NSArray *clientArray = [clients objectForKey:[sortedKeys objectAtIndex:section]];
	if( (NSNull*)clientArray == [NSNull null] ) {
		return nil;
	}
	return [sortedKeys objectAtIndex:section];
}


#pragma mark -
#pragma mark Content Filtering
#pragma mark -

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// First clear the filtered array.
	[filteredList removeAllObjects]; 
	// Add matching Clients
	for( NSArray* arr in [clients allValues] ) {
		if( (NSNull*)arr != [NSNull null] ) {
			for( Client* cl in arr ) {
				NSString *first = [cl getFirstName];
				NSString *last = [cl getLastName];
				if( (first && [[first lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0) || (last && [[last lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0) ) {
					[filteredList addObject:cl];
				}
			}
		}
	}
	
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
#pragma mark -

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
	[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
