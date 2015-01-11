//
//  CalendarListViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/24/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentViewController.h"
#import "Client.h"
#import "Project.h"
#import "Service.h"
#import "CalendarListViewController.h"


@implementation CalendarListViewController

@synthesize appointmentCell, parentsNavigationController, tblList;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	[self.view setUserInteractionEnabled:NO];
	[[PSADataManager sharedInstance] showActivityIndicator];
	[[PSADataManager sharedInstance] setDelegate:self];
	[[PSADataManager sharedInstance] getDictionaryOfAppointmentsFor30DaysStarting:[NSDate date]];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.parentsNavigationController = nil;
	self.tblList = nil;
	[appointments release];
	[headerViews release];
	[sortedKeys release];
    [super dealloc];
}

- (void) dataManagerReturnedArray:(NSArray*)theArray {
	if( appointments )	[appointments release];
	if( sortedKeys )	[sortedKeys release];
	// Get dictionary from array...
	appointments = [[PSADataManager sharedInstance] getDictionaryOfAppointmentsForArray:theArray];
	sortedKeys = [[[appointments allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
	[tblList reloadData];
	[[PSADataManager sharedInstance] setDelegate:nil];
	[[PSADataManager sharedInstance] hideActivityIndicator];
	[self.view setUserInteractionEnabled:YES];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -
- (void) goToToday {
	NSArray *paths = [tblList indexPathsForRowsInRect:CGRectMake(0, 0, 320, 80)];
	NSIndexPath *path = nil;
	if( paths.count > 0 ) {
		path = [paths objectAtIndex:0];
	}
	[tblList scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	//if( tv == self.searchDisplayController.searchResultsTableView )	return 1;
	return [sortedKeys count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// Placeholders
	UIView *headerView = nil;
	UILabel *lbDay = nil;
	UILabel *lbDate = nil;
	//
	if( headerViews == nil ) {
		headerViews = [[NSMutableArray alloc] initWithCapacity:8];
		for( int i=0; i<8; i++ ) {
			// Create and set the header view
			headerView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 320, 22)];
			UIImage *bg = [UIImage imageNamed:@"calendarListHeaderBackground.png"];
			UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
			headerView.backgroundColor = bgColor;
			headerView.tag = -1;
			// Labels
			UIFont *font = [UIFont boldSystemFontOfSize:18];
			CGRect dayRect = CGRectMake( 0, 0, 85, headerView.frame.size.height );
			CGRect dateRect = CGRectMake( 175, 0, 139, headerView.frame.size.height);
			CGSize size = CGSizeMake( 0, 1 );
			//
			lbDay = [[UILabel alloc] initWithFrame:dayRect];
			lbDay.backgroundColor = bgColor;
			lbDay.opaque = YES;
			lbDay.font = font;
			lbDay.shadowOffset = size;
			lbDay.tag = 99;
			lbDay.textAlignment = NSTextAlignmentRight;
			//
			lbDate = [[UILabel alloc] initWithFrame:dateRect];
			lbDate.backgroundColor = bgColor;
			lbDate.opaque = YES;
			lbDate.font = font;
			lbDate.shadowOffset = size;
			lbDate.tag = 98;
			lbDate.textAlignment = NSTextAlignmentRight;
			//
			[headerView addSubview:lbDay];
			[headerView addSubview:lbDate];
			[lbDay release];
			[lbDate release];
			//
			[headerViews addObject:headerView];
			[headerView release];
			//
			[bgColor release];
		}
	}
	
	// Find the header for this section
	for( UIView *tmpView in headerViews ) {
		if( tmpView.tag == section ) {
			headerView = tmpView;
			break;
		}
	}
	
	// If the header is still nil, look for one to reuse (no superview)
	//if( headerView == nil )
    {
		for( UIView *tmpView in headerViews ) {
			if( tmpView.superview == nil ) {
				headerView = tmpView;
				break;
			}
		}
		
		if( headerView != nil ) {
			lbDay = (UILabel*)[headerView viewWithTag:99];
			lbDate = (UILabel*)[headerView viewWithTag:98];
			// Set the tag
			headerView.tag = section;
			// Font colors
			if( section == 0 ) {
				lbDay.textColor = [UIColor colorWithRed:0 green:.45 blue:.9 alpha:1];
				lbDate.textColor = lbDay.textColor;
				lbDay.shadowColor = [UIColor whiteColor];
				lbDate.shadowColor = [UIColor whiteColor];
			} else {
				lbDay.textColor = [UIColor whiteColor];
				lbDate.textColor = [UIColor whiteColor];
				lbDay.shadowColor = [UIColor grayColor];
				lbDate.shadowColor = [UIColor grayColor];
			}
			
			NSString *realString = [sortedKeys objectAtIndex:section];
			NSArray *substrings = [realString componentsSeparatedByString:@"_"];
			if( substrings.count > 2 ) {
				lbDay.text = [[substrings objectAtIndex:2] substringToIndex:3];
				lbDate.text = [substrings objectAtIndex:1];
			}
		}
	}
	
	return headerView;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	//if( tableView == self.searchDisplayController.searchResultsTableView )	return nil;
	NSArray *substrings = [[sortedKeys objectAtIndex:section] componentsSeparatedByString:@"_"];
	if( substrings.count > 2 ) {
		// The last two at index 1, 2 is what we want
		return [substrings objectAtIndex:1];
	}
	return @"";
}
*/

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	//if( aTableView == self.searchDisplayController.searchResultsTableView )	return filteredList.count;
	return [[appointments objectForKey:[sortedKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblList dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    if (cell == nil) {
		// Load the NIB
		[[NSBundle mainBundle] loadNibNamed:@"AppointmentCell" owner:self options:nil];
		cell = appointmentCell;
		self.appointmentCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

	/*
	 if( aTableView == self.searchDisplayController.searchResultsTableView ) {
	 tmp = [filteredList objectAtIndex:indexPath.row];
	 } else {
	 tmp = [[services objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	 }*/
	
	Appointment *tmp = [[appointments objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	// Date/Time
	NSString *time = [[PSADataManager sharedInstance] getStringForTime:tmp.dateTime withFormat:NSDateFormatterShortStyle];
	NSArray	*timeArray = [time componentsSeparatedByString:@" "];
	UILabel *label = (UILabel*)[cell viewWithTag:11];
	label.text = [timeArray objectAtIndex:0];

	UILabel *label2 = (UILabel*)[cell viewWithTag:12];
	if( timeArray.count > 1 ) {
		label2.text = [timeArray objectAtIndex:1];		
	} else {
		label2.text = nil;
	}
	
	// Name and Service Name
	if( tmp.type == iBizAppointmentTypeSingleService ) {
		[cell viewWithTag:10].backgroundColor = ((Service*)tmp.object).color;
		//
		label = (UILabel*)[cell viewWithTag:13];
		NSString *text = [[NSString alloc] initWithFormat:@"%@ - %@", ((Service*)tmp.object).serviceName, (tmp.client) ? [tmp.client getClientName] : @"No Client"];
		label.text = text;
		[text release];
	} else if( tmp.type == iBizAppointmentTypeProject ) {
		[cell viewWithTag:10].backgroundColor = [UIColor colorWithRed:.596 green:.678 blue:.843 alpha:.7];
		//
		label = (UILabel*)[cell viewWithTag:13];
		NSString *text = [[NSString alloc] initWithFormat:@"%@ - %@", ((Project*)tmp.object).name, (tmp.client) ? [tmp.client getClientName] : @"No Client"];
		label.text = text;
		[text release];
	} else if( tmp.type == iBizAppointmentTypeBlock ) {
		[cell viewWithTag:10].backgroundColor = [UIColor colorWithRed:.165 green:.733 blue:.945 alpha:.7];
		//
		label = (UILabel*)[cell viewWithTag:13];
		NSString *text = [[NSString alloc] initWithFormat:@"%@", (tmp.notes) ? tmp.notes : @"Block"];
		label.text = text;
		[text release];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	/*
	// Call the delegate method
	if( tableView == self.searchDisplayController.searchResultsTableView )	{
		[serviceDelegate selectionMadeWithService:[filteredList objectAtIndex:indexPath.row]];
	} else {
		[serviceDelegate selectionMadeWithService:[[services objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
	}
	*/
	
	AppointmentViewController *cont = [[AppointmentViewController alloc] initWithNibName:@"AppointmentView" bundle:nil];
	cont.isEditing = NO;
	cont.appointment = [[appointments objectForKey:[sortedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	[self.parentsNavigationController pushViewController:cont animated:YES];
	[cont release];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *label2 = (UILabel*)[cell viewWithTag:12];
	UILabel *detail = (UILabel*)[cell viewWithTag:13];
	if( label2.text ) {
		detail.frame = CGRectMake( 103, 7, 190, 31 );
	} else {
		detail.frame = CGRectMake( 73, 7, 220, 31 );
	}
}

@end
