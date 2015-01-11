//
//  ClientHistoryViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Transaction.h"
#import "TransactionViewController.h"
#import "ClientTransactionsViewController.h"


@implementation ClientTransactionsViewController

@synthesize tblTransactions, transactionsCell;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle { 
    self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) { 
        self.title = @"Register";
		self.tabBarItem.image = [UIImage imageNamed:@"iconTransactions.png"];
    }
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    return self; 
} 


- (void) viewDidLoad {
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
	if( transactions ) {
		[transactions release];
	}
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getTransactionsForClient:client];
}
 

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	[super viewDidUnload];
}


- (void)dealloc {
	[formatter release];
	self.tblTransactions = nil;
	[transactions release];
    [super dealloc];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	// Get dictionary from array...
	transactions = [theArray retain];
	// Reload and resume normal activity
	[tblTransactions reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
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
	return transactions.count;
}

/*
 *	Creates or reuses a cell, sets it's values, and returns for display
 */
- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblTransactions dequeueReusableCellWithIdentifier:@"TransactionsTableCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"TransactionsTableCell" owner:self options:nil];
		cell = transactionsCell;
		self.transactionsCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	Transaction *tmp = [transactions objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	
	NSString *str = nil;
	
	if( tmp.dateVoided ) {
		lbName.text = @"VOID";
		str = [[NSString alloc] initWithFormat:@"%@", [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.dateVoided]];
	} else if( tmp.dateClosed ) {
		lbName.text = @"CLOSED";
		str = [[NSString alloc] initWithFormat:@"%@", [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.dateClosed]];
	} else if( tmp.dateOpened ) {
		lbName.text = @"OPEN";
		str = [[NSString alloc] initWithFormat:@"%@", [[PSADataManager sharedInstance] getStringForAppointmentDate:tmp.dateOpened]];
	}
	lbStatusTime.text = str;
	[str release];
	
	lbAmount.text = [formatter stringFromNumber:tmp.totalForTable];
	
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
	Transaction *tmp = [transactions objectAtIndex:indexPath.row];
	tmp.client = client;
	if( tmp.isHydrated == NO )	[tmp hydrate];
	TransactionViewController *cont = [[TransactionViewController alloc] initWithNibName:@"TransactionView" bundle:nil];
	cont.transaction = tmp;
	[self.navigationController pushViewController:cont animated:YES];
	[cont release];
}

/*
 *	Colorize row backgrounds based on status
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	Transaction *tmp = [transactions objectAtIndex:indexPath.row];
	
	UILabel *lbName = (UILabel*)[cell viewWithTag:99];
	UILabel *lbStatusTime = (UILabel*)[cell viewWithTag:98];
	UILabel *lbAmount = (UILabel*)[cell viewWithTag:97];
	UIColor *color = nil;
	if( tmp.dateVoided ) {
		color = [UIColor colorWithRed:.94 green:.94 blue:.94 alpha:1];
	} else if( tmp.dateClosed ) {
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
