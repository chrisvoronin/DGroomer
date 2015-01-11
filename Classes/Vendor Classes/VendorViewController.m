//
//  VendorViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Vendor.h"
#import "VendorEditViewController.h"
#import "VendorViewController.h"


@implementation VendorViewController

@synthesize tblVendor, vendor;

- (void) viewDidLoad {
	self.title = @"Vendor";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblVendor setBackgroundColor:bgColor];
	[bgColor release];
	// Edit Button
	UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
	self.navigationItem.rightBarButtonItem = btnEdit;
	[btnEdit release];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {

	[tblVendor reloadData];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.tblVendor = nil;
	[vendor release];
    [super dealloc];
}

- (void) edit {
	VendorEditViewController *cont = [[VendorEditViewController alloc] initWithNibName:@"VendorEditView" bundle:nil];
	cont.vendor = vendor;
	UIBarButtonItem *cancel  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerAnimated:)];
	cont.navigationItem.leftBarButtonItem = cancel;
	[cancel release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cont];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:nav animated:YES completion:nil];
	[cont release];
	[nav release];
}

#pragma mark -
#pragma mark MessageUI Delegate Methods
#pragma mark -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error { 
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	switch ( section ) {
		case 0:		return 2;
		case 1:
			if( vendor.vendorAddress2 && ![vendor.vendorAddress2 isEqualToString:@""] )	{
				return 3;
			} else {
				return 2;
			}
		case 2:		return 3;
	}
	return 1;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"VendorCell"];
    if( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"VendorCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryNone;
		//
		cell.detailTextLabel.minimumFontSize = 12;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		
    }
	
	cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
	cell.detailTextLabel.numberOfLines = 1;
	
	switch ( indexPath.section ) {
		case 0:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = vendor.vendorName;
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Contact";
				cell.detailTextLabel.text = vendor.vendorContact;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Address";
					cell.detailTextLabel.text = vendor.vendorAddress1;
					break;
				case 1:
					cell.textLabel.text = @"";
					cell.detailTextLabel.text = vendor.vendorAddress2;					
					if( vendor.vendorAddress2 && ![vendor.vendorAddress2 isEqualToString:@""] ){
						break;	// Otherwise pass through
					}
				case 2:
					cell.textLabel.text = @"City, ST";
					
					NSString *city = nil;
					NSString *state = nil;
					if( vendor.vendorCity && ![vendor.vendorCity isEqualToString:@""] ){
						city = vendor.vendorCity;
					}
					if( vendor.vendorState && ![vendor.vendorState isEqualToString:@""] ){
						state = vendor.vendorState;
					}
					
					NSString *str = nil;
					if( city && state && vendor.vendorZipcode > 0 ) {
						str = [[NSString alloc] initWithFormat:@"%@, %@ %d", city, state, vendor.vendorZipcode];
					} else if( city && state ) {
						str = [[NSString alloc] initWithFormat:@"%@, %@", city, state];
					} else if( city && !state && vendor.vendorZipcode > 0 ) {
						str = [[NSString alloc] initWithFormat:@"%@, %d", city, vendor.vendorZipcode];
					} else if( !city && state && vendor.vendorZipcode > 0 ) {
						str = [[NSString alloc] initWithFormat:@"%@, %d", state, vendor.vendorZipcode];
					} else if( city ) {
						str = [[NSString alloc] initWithFormat:@"%@", city];
					} else if( state ) {
						str = [[NSString alloc] initWithFormat:@"%@", state];
					} else if( vendor.vendorZipcode > 0 ) {
						str = [[NSString alloc] initWithFormat:@"%d", vendor.vendorZipcode];
					} else {
						str = [[NSString alloc] initWithString:@""];
					}

					cell.detailTextLabel.text = str;
					[str release];
					break;
			}			
			break;
		case 2:
			if( indexPath.row == 0 ) {
				cell.textLabel.text = @"Phone";
				cell.detailTextLabel.text = vendor.vendorTelephone;
			} else if( indexPath.row == 1 ) {
				cell.textLabel.text = @"Fax";
				cell.detailTextLabel.text = vendor.vendorFax;
			} else if( indexPath.row == 2 ) {
				cell.textLabel.text = @"Email";
				cell.detailTextLabel.text = vendor.vendorEmail;
			}
			break;
	}
	
	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// GoTo
	switch ( indexPath.section ) {
		case 2:
			if( indexPath.row == 0 ) {
				// Initiate Phone Call on iPhone only
				if( [[[UIDevice currentDevice] model] hasPrefix:@"iPhone"] ) {
					NSString *urlString = [[NSString alloc] initWithFormat:@"tel://%@", vendor.vendorTelephone];
					NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
					[[UIApplication sharedApplication] openURL:url];
					[urlString release];
					[url release];
				} // Otherwise do nothing
			} else if( indexPath.row == 2 ) {
				// Open Email
				if( [MFMailComposeViewController canSendMail] ) {
					MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
					picker.navigationBar.tintColor = [UIColor blackColor];
					picker.mailComposeDelegate = self; 
					// Set up the recipients
					NSArray *toRecipients = [NSArray arrayWithObjects:vendor.vendorEmail, nil]; 
					[picker setToRecipients:toRecipients]; 
					// Present the mail composition interface. 
					[self presentViewController:picker animated:YES completion:nil]; 
					[picker release];
				} else {
					NSString *msg = [[NSString alloc] initWithFormat:@"Your device is not ready to send email. This is not a %@ setting, you must create an email account on your iPhone, iPad, or iPod Touch.\n\nYou can add an account by exiting the app, going to Settings > Mail, Contacts, Calendars > Add Account...", APPLICATION_NAME];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Email Vendor!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[msg release];
					[alert show];	
					[alert release];
				}
			}
			break;
	}
}


@end
