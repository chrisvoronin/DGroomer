//
//  ReportsDateRangeViewController.m
//  myBusiness
//
//  Created by David J. Maier on 1/29/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "CloseoutHistoryViewController.h"
#import "CreditCardPaymentsTableViewController.h"
#import "DailyCloseoutViewController.h"
#import "ProductHistoryViewController.h"
#import "PSADataManager.h"
#import "Report.h"
#import "TransactionsTableViewController.h"
#import "UnpaidInvoiceTableViewController.h"
#import "ReportsDateRangeViewController.h"


@implementation ReportsDateRangeViewController

@synthesize report, picker, swEntire, tblTimes;

- (void) viewDidLoad {
	self.title = @"Report Range";
	//
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundAquamarine.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblTimes setBackgroundColor:bgColor];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];
	// Done Button
	UIBarButtonItem *btnGenerate = [[UIBarButtonItem alloc] initWithTitle:@"Generate" style:UIBarButtonItemStylePlain target:self action:@selector(generate)];
	self.navigationItem.rightBarButtonItem = btnGenerate;
	[btnGenerate release];
	// Fixes the time zone issues in 4.0
	picker.calendar = [NSCalendar autoupdatingCurrentCalendar];
	//
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[report release];
	self.picker = nil;
	self.swEntire = nil;
	self.tblTimes = nil;
    [super dealloc];
}


- (void) generate {
	if( report.type == PSAReportTypeCloseoutHistory ) {
		CloseoutHistoryViewController *cont = [[CloseoutHistoryViewController alloc] initWithNibName:@"CloseoutHistoryView" bundle:nil];
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else if( report.type == PSAReportTypeConsolidatedCloseout ) {
		DailyCloseoutViewController *cont = [[DailyCloseoutViewController alloc] initWithNibName:@"DailyCloseoutView" bundle:nil];
		cont.isCloseoutReport = YES;
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else if( report.type == PSAReportTypeInvoiceHistory ) {
		UnpaidInvoiceTableViewController *cont = [[UnpaidInvoiceTableViewController alloc] initWithNibName:@"UnpaidInvoiceTableView" bundle:nil];
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else if( report.type == PSAReportTypeProductHistory ) {
		ProductHistoryViewController *cont = [[ProductHistoryViewController alloc] initWithNibName:@"ProductHistoryView" bundle:nil];
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else if( report.type == PSAReportTypeProductInventory ) {
		
	} else if( report.type == PSAReportTypeServiceHistory ) {
		
	} else if( report.type == PSAReportTypeCreditPaymentsHistory ) {
		CreditCardPaymentsTableViewController *cont = [[CreditCardPaymentsTableViewController alloc] initWithNibName:@"CreditCardPaymentsTableView" bundle:nil];
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else if( report.type == PSAReportTypeTransactionHistory ) {
		TransactionsTableViewController *cont = [[TransactionsTableViewController alloc] initWithNibName:@"TransactionsTableView" bundle:nil];
		cont.report = report;
		[self.navigationController pushViewController:cont animated:YES];
		[cont release];
	} else {
		NSString *msg = [[NSString alloc] initWithFormat:@"%@ could not generate your report because the report type is unknown.\n\nPlease retry, and report this error to our support if it occurs again.", APPLICATION_NAME];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unknown Report Type!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[msg release];
		[alert show];
		[alert release];
	}
}

- (IBAction) adjustEnitreHistory:(id)sender {
	report.isEntireHistory = swEntire.on;
	[tblTimes reloadData];
}

- (IBAction) dateChanged:(id)sender {
	NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:picker.date];
	if( tableIndexEditing == 0 ) {
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		report.dateStart = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
	} else if( tableIndexEditing == 1 ) {
		[comps setHour:23];
		[comps setMinute:59];
		[comps setSecond:59];
		report.dateEnd = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
	}
	[tblTimes reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if ( report.isEntireHistory )	return 0;
	return 2;
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblTimes dequeueReusableCellWithIdentifier:@"TimeCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TimeCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
    }
	
	switch ( indexPath.row ) {
		case 0: {
			cell.textLabel.text = @"Start";
			if( report.dateStart ) {
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:report.dateStart withFormat:NSDateFormatterLongStyle];
			} else {
				cell.detailTextLabel.text = @"First Record";
			}
			break;
		}
		case 1: {
			cell.textLabel.text = @"End";
			if( report.dateEnd ) {
				cell.detailTextLabel.text = [[PSADataManager sharedInstance] getStringForDate:report.dateEnd withFormat:NSDateFormatterLongStyle];
			} else {
				cell.detailTextLabel.text = @"Last Record";
			}
			break;
		}
	}
	
	return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	tableIndexEditing = indexPath.row;
	//
	if( indexPath.row == 0 ) {
		if( report.dateStart ) {
			picker.date = report.dateStart;
		}
	} else if( indexPath.row == 1 ) {
		if( report.dateEnd ) {
			picker.date = report.dateEnd;
		}
	}
	// Reload to get proper background view for the cells
	[tableView reloadData];	
}

/*
 *	Maintain a background color on the row that is being "edited".
 *	This is the way Apple shows selection in the Calendar app, so it should be OK.
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {	
	// Change the background of the "editing" cell, or revert to the "unediting" cell style
	if( tableIndexEditing == indexPath.row ) {
		UIImage *bg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"selectedCellBackground" ofType:@"png"]];
		UIColor *color = [[UIColor alloc] initWithPatternImage:bg];
		cell.backgroundColor = color;
		[color release];
		[bg release];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor whiteColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	} else {
		cell.backgroundColor = [UIColor whiteColor];
		cell.detailTextLabel.textColor = [UIColor colorWithRed:.22 green:.33 blue:.53 alpha:1];
		cell.textLabel.textColor = [UIColor blackColor];
	}
}


@end
