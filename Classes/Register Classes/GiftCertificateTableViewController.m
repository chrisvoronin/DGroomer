//
//  GiftCertificateTableViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/23/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "GiftCertificate.h"
#import "GiftCertificateViewController.h"
#import "PSADataManager.h"
#import "GiftCertificateTableViewController.h"


@implementation GiftCertificateTableViewController

@synthesize certificateCell, delegate, tblCertificates;

- (void) viewDidLoad {
	if( !delegate )	delegate = self;
	//
	self.title = @"Gift Certificates";
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !certificates ) {
		certificates = [[PSADataManager sharedInstance] getGiftCertificates];
	}
	[tblCertificates reloadData];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.tblCertificates = nil;
	[certificates release];
	[formatter release];
    [super dealloc];
}

#pragma mark -
#pragma mark Delegate Method
#pragma mark -

- (void) selectionMadeWithCertificate:(GiftCertificate*)theCertificate {
	// GoTo
	GiftCertificateViewController *cont = [[GiftCertificateViewController alloc] initWithNibName:@"GiftCertificateView" bundle:nil];
	cont.certificate = theCertificate;
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	Just 1 section
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Need a row for every color line except custom (index 0)...
 */
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return certificates.count;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"GiftCertificateTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"GiftCertificateTableCell" owner:self options:nil];
		cell = certificateCell;
		self.certificateCell = nil;
    }
	
	GiftCertificate *cert = [certificates objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	if( cert.recipientFirst && cert.recipientLast ) {
		lbName.text = [NSString stringWithFormat:@"%@, %@", cert.recipientLast, cert.recipientFirst];
	} else if( cert.recipientFirst ) {
		lbName.text = [NSString stringWithFormat:@"%@", cert.recipientFirst];
	} else if( cert.recipientLast ) {
		lbName.text = [NSString stringWithFormat:@"%@", cert.recipientLast];
	} else {
		lbName.text = @"No Name";
	}

	NSString *str = [[NSString alloc] initWithFormat:@"id: %d  exp: %@", cert.certificateID, [[PSADataManager sharedInstance] getStringForDate:cert.expiration withFormat:NSDateFormatterShortStyle] ];
	lbStatusTime.text = str;
	[str release];
	
	lbAmount.text = [formatter stringFromNumber:[NSNumber numberWithFloat:[cert.amountPurchased doubleValue]-[cert.amountUsed doubleValue]]];
	
	return cell;
}

/*
 *	Just deselects the row
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// Get rid of the selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	GiftCertificate *cert = [certificates objectAtIndex:indexPath.row];
	if( cert ) {
		[self.delegate selectionMadeWithCertificate:cert];
	}
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	UIColor *color = nil;
	if( indexPath.row % 2 == 0 ) {
		color = [UIColor colorWithRed:.94 green:.94 blue:.94 alpha:1];
	} else {
		color = [UIColor whiteColor];
	}
	lbName.backgroundColor = color;
	lbStatusTime.backgroundColor = color;
	lbAmount.backgroundColor = color;
	cell.backgroundColor = color;
}
@end
