//
//  ProjectViewController.m
//  myBusiness
//
//  Created by David J. Maier on 3/18/10.
//  Copyright 2010 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "Project.h"
#import "ProjectAppointmentsViewController.h"
#import "ProjectEditViewController.h"
#import "ProjectEstimatesViewController.h"
#import "ProjectNotesEntryViewController.h"
#import "ProjectPaymentsViewController.h"
#import "ProjectProductsViewController.h"
#import "ProjectService.h"
#import "ProjectServicesViewController.h"
#import "PSAAppDelegate.h"
#import "ProjectViewController.h"


@implementation ProjectViewController

@synthesize project, projectButtonsCell, projectInformationCell, projectItemsCell, projectNotesCell, projectPaymentItemsCell, projectValue2Cell, tblProject;


- (void) viewDidLoad {
	self.title = @"Project";
	// Set the background color to a nice blue image
	UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundBlue.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblProject setBackgroundColor:bgColor];
	[bgColor release];
	// Edit Button
	if( !project.dateCompleted ) {
		UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		self.navigationItem.rightBarButtonItem = btnEdit;
		[btnEdit release];
	}
	//
	formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( !project.isHydrated ) {
		[project hydrate];
	}
	[tblProject reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	if( project.isHydrated ) {
		[project dehydrate];
	}
	[project release];
	[formatter release];
	self.tblProject = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods
#pragma mark -

- (IBAction) completeProject:(id)sender {
	if( project.dateCompleted ) {
		project.dateCompleted = nil;
		[[PSADataManager sharedInstance] saveProject:project];
		UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		self.navigationItem.rightBarButtonItem = btnEdit;
		[btnEdit release];
	} else {
		project.dateCompleted = [NSDate date];
		// Stop any active timers...
		for( ProjectService *tmp in project.services ) {
			if( tmp.isTiming ) {
				[tmp stopTiming];
			}
		}
		// Save
		[[PSADataManager sharedInstance] saveProject:project];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You've finished your project!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.navigationItem.rightBarButtonItem = nil;
	}
	[tblProject reloadData];
}

- (IBAction) deleteProject:(id)sender {
	NSArray *estimates = [project.payments objectForKey:[project getKeyForEstimates]];
	NSArray *invoices = [project.payments objectForKey:[project getKeyForInvoices]];
	if( estimates.count > 0 || invoices.count > 0 ) {
		UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete Project!" message:@"You must delete any estimates or invoices before deleting a project!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		// Display action sheet
		UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"This will delete all remaining project appointments and data! Any non-invoiced transactions will remain, but have no reference to the project.\n\nDelete Project?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
		[alert showInView:self.view];	
		[alert release];
	}
}

- (void) edit {
	ProjectEditViewController *pvc = [[ProjectEditViewController alloc] initWithNibName:@"ProjectEditView" bundle:nil];
	pvc.project = project;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pvc];
	nav.navigationBar.tintColor = [UIColor blackColor];
	[pvc release];
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods
#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == 0 ) {
		[[PSADataManager sharedInstance] removeProject:project];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	switch ( section ) {
		case 0:	{
			if( project.dateDue || project.dateCompleted ) {
				return 3;
			}
			return 2;
		}
		case 1:		return 1;
		case 2:		return 4;
		case 3:		return 1;
		case 4:		return 1;
	}
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ( indexPath.section ) {
		case 0:		return 44;
		case 1:		return 44;
		case 2:		return 44;
		case 3:		return 92;
		case 4:		return 92;
	}
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
	if( indexPath.section == 0 ) {
		if( indexPath.row == 0 ) {
			identifier = @"ProjectInformationCell";
		} else {
			identifier = @"ProjectClientDueDateCell";
		}
	} else if( indexPath.section == 1 ) {
		identifier = @"ProjectViewCellValue2";
	} else if( indexPath.section == 2 ) {
		if( indexPath.row == 3 ) {
			identifier = @"ProjectPaymentItemsCell";
		} else {
			identifier = @"ProjectItemsCell";
		}
	} else if( indexPath.section == 3 ) {
		identifier = @"ProjectNotesCell";
	} else if( indexPath.section == 4 ) {
		identifier = @"ProjectButtonsCell";
	}
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
		// Load the NIB
		if( indexPath.section == 0 ) {
			if( indexPath.row == 0 ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = projectInformationCell;
				self.projectInformationCell = nil;
			} else {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
				cell.accessoryType = UITableViewCellAccessoryNone;
				UIColor *tmp = cell.textLabel.textColor;
				cell.textLabel.textColor = cell.detailTextLabel.textColor;
				cell.detailTextLabel.textColor = tmp;
				
				cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
				cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
				
				cell.textLabel.textAlignment = NSTextAlignmentLeft;
				cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
			}
		} else if( indexPath.section == 1 ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = projectValue2Cell;
			self.projectValue2Cell = nil;
		} else if( indexPath.section == 2 ) {
			if( indexPath.row == 3 ) {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = projectPaymentItemsCell;
				self.projectPaymentItemsCell = nil;
			} else {
				[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
				cell = projectItemsCell;
				self.projectItemsCell = nil;
			}
		} else if( indexPath.section == 3 ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = projectNotesCell;
			self.projectNotesCell = nil;
			UITextView *tvNotes = (UITextView*)[cell viewWithTag:99];
			tvNotes.font = [UIFont systemFontOfSize:14];
		} else if( indexPath.section == 4 ) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = projectButtonsCell;
			self.projectButtonsCell = nil;
		}
	}
	
	if( [identifier isEqualToString:@"ProjectClientDueDateCell"] ) {
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	switch (indexPath.section) {
		case 0: {
			switch ( indexPath.row ) {
				case 0: {
					UILabel *lbName = (UILabel*)[cell viewWithTag:99];
					lbName.text = project.name;
					break;
				}
				case 1: {
					cell.textLabel.text = @"Client";
					cell.detailTextLabel.text = [project.client getClientName];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleGray;
					break;
				}
				case 2: {
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					if( project.dateCompleted ) {
						cell.textLabel.text = @"Completed";
						NSString *due = [[NSString alloc] initWithFormat:@"%@", [[PSADataManager sharedInstance] getStringForDate:project.dateCompleted withFormat:NSDateFormatterLongStyle]];
						cell.detailTextLabel.text = due;
						[due release];
					} else if( project.dateDue ) {
						cell.textLabel.text = @"Due Date";
						NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
						[comps setHour:0];
						[comps setMinute:0];
						[comps setSecond:0];
						NSDate *todayNoTime = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];				
						comps = nil;
						comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSDayCalendarUnit fromDate:todayNoTime toDate:project.dateDue options:0];
						if( [comps day] > 0 ) {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (%d day%@)", [[PSADataManager sharedInstance] getStringForDate:project.dateDue withFormat:NSDateFormatterLongStyle], [comps day], ([comps day] == 1) ? @"" : @"s"];
							cell.detailTextLabel.text = due;
							[due release];
						} else if( [comps day] == 0 ) {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (Today!)", [[PSADataManager sharedInstance] getStringForDate:project.dateDue withFormat:NSDateFormatterLongStyle], [comps day], ([comps day] == 1) ? @"" : @"s"];
							cell.detailTextLabel.textColor = [UIColor blueColor];
							cell.detailTextLabel.text = due;
							[due release];
						} else {
							NSString *due = [[NSString alloc] initWithFormat:@"%@ (overdue)", [[PSADataManager sharedInstance] getStringForDate:project.dateDue withFormat:NSDateFormatterLongStyle]];
							cell.detailTextLabel.textColor = [UIColor redColor];
							cell.detailTextLabel.text = due;
							[due release];
						}
					} else {
						cell.textLabel.text = @"Due Date";
						cell.detailTextLabel.text = @"";
					}
					break;
				}
			}
			break;
		}
		case 1: {
			UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:98];
			NSString *str = [[NSString alloc] initWithFormat:@"%d", project.appointments.count];
			detailTextLabel.text = str;
			[str release];
			break;
		}
		case 2: {
			if( indexPath.row == 0 ) {
				UILabel *lbTitleCol2 = (UILabel*)[cell viewWithTag:99];
				UILabel *lbValueCol1 = (UILabel*)[cell viewWithTag:98];
				UILabel *lbValueCol2 = (UILabel*)[cell viewWithTag:97];
				UILabel *lbValueCol3 = (UILabel*)[cell viewWithTag:96];
				UILabel *lbType = (UILabel*)[cell viewWithTag:95];
				lbType.text = @"Services";
				lbTitleCol2.text = @"Hrs.";
				NSString *count = [[NSString alloc] initWithFormat:@"%d", project.services.count];
				lbValueCol1.text = count;
				[count release];
				NSArray *totals = [project getServiceTotals];
				lbValueCol2.text = [[PSADataManager sharedInstance] getShortStringOfHoursAndMinutesForSeconds:[(NSNumber*)[totals objectAtIndex:0] integerValue]];
				lbValueCol3.text = [formatter stringFromNumber:[totals objectAtIndex:1]];
				break;
			} else if( indexPath.row == 1 ) {
				UILabel *lbTitleCol2 = (UILabel*)[cell viewWithTag:99];
				UILabel *lbValueCol1 = (UILabel*)[cell viewWithTag:98];
				UILabel *lbValueCol2 = (UILabel*)[cell viewWithTag:97];
				UILabel *lbValueCol3 = (UILabel*)[cell viewWithTag:96];
				UILabel *lbType = (UILabel*)[cell viewWithTag:95];
				lbType.text = @"Products";
				lbTitleCol2.text = @"Qty.";
				NSString *count = [[NSString alloc] initWithFormat:@"%d", project.products.count];
				lbValueCol1.text = count;
				[count release];
				NSArray *totals = [project getProductTotals];
				NSString *amt = [[NSString alloc] initWithFormat:@"%d", [(NSNumber*)[totals objectAtIndex:0] integerValue]];
				lbValueCol2.text = amt;
				[amt release];
				lbValueCol3.text = [formatter stringFromNumber:[totals objectAtIndex:1]];
			} else if( indexPath.row == 2 ) {
				UILabel *lbTitleCol2 = (UILabel*)[cell viewWithTag:99];
				UILabel *lbValueCol1 = (UILabel*)[cell viewWithTag:98];
				UILabel *lbValueCol2 = (UILabel*)[cell viewWithTag:97];
				UILabel *lbValueCol3 = (UILabel*)[cell viewWithTag:96];
				UILabel *lbType = (UILabel*)[cell viewWithTag:95];
				lbType.text = @"Estimates";
				lbTitleCol2.text = @"Accepted";
				NSString *count = [[NSString alloc] initWithFormat:@"%d", [[project.payments objectForKey:[project getKeyForEstimates]] count]];
				lbValueCol1.text = count;
				[count release];
				NSArray *totals = [project getEstimateTotals];
				NSString *amt = [[NSString alloc] initWithFormat:@"%d", [(NSNumber*)[totals objectAtIndex:0] integerValue]];
				lbValueCol2.text = amt;
				[amt release];
				lbValueCol3.text = [formatter stringFromNumber:[totals objectAtIndex:1]];
			} else {
				UILabel *lbValueCol1 = (UILabel*)[cell viewWithTag:99];
				UILabel *lbValueCol2 = (UILabel*)[cell viewWithTag:98];
				UILabel *lbTitleCol1 = (UILabel*)[cell viewWithTag:97];
				double owed = [[project getAmountOwed] doubleValue];
				if( owed >= 0.0 ) {
					lbTitleCol1.text = @"Owed";
					lbValueCol1.text = [formatter stringFromNumber:[NSNumber numberWithFloat:owed]];
				} else {
					lbTitleCol1.text = @"Change";
					lbValueCol1.text = [formatter stringFromNumber:[NSNumber numberWithFloat:owed*-1]];
				}
				lbValueCol2.text = [formatter stringFromNumber:[project getAmountPaid]];
			}
			break;
		}
		case 3: {
			// Notes
			UITextView *tvNotes = (UITextView*)[cell viewWithTag:99];
			tvNotes.text = project.notes;
			break;
		}
		case 4: {
			// Change the button
			if( project.dateCompleted ) {
				[[cell viewWithTag:99] setHidden:YES];
				[[cell viewWithTag:98] setHidden:NO];
				//btnComplete.selected = YES;
			} else {
				[[cell viewWithTag:99] setHidden:NO];
				[[cell viewWithTag:98] setHidden:YES];
			}
			break;
		}
	}
	
	return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if( indexPath.section >= 3 ) {
		// Get rid of background and border
		[cell setBackgroundView:nil];
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// don't keep the table selection
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	switch (indexPath.section) {
		case 0: {
			if( indexPath.row == 1 ) {
				if( project.client.clientID == 0 || [project.client getPerson] ) {
					ABPersonViewController *personVC = [[ABPersonViewController alloc] init];
					((ABPersonViewController*)personVC).personViewDelegate = (PSAAppDelegate *)[[UIApplication sharedApplication] delegate];
					((ABPersonViewController*)personVC).addressBook = [[PSADataManager sharedInstance] addressBook];
					((ABPersonViewController*)personVC).displayedPerson = [project.client getPerson];
					if( ((ABPersonViewController*)personVC).displayedPerson ) {
						((ABPersonViewController*)personVC).allowsEditing = YES;
					} else {
						((ABPersonViewController*)personVC).allowsEditing = NO;
					}
					[self.navigationController pushViewController:personVC animated:YES];
					// Change the ABPersonViewController's backgrounds
					UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGold.png"];
					UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
					personVC.view.backgroundColor = bgColor;
					for( UIView *sub in personVC.view.subviews ) {
						sub.backgroundColor = bgColor;
					}
					[bgColor release];
					// Done
					[personVC release];
				}
			}
			break;
		}
		case 1: {
			ProjectAppointmentsViewController *cont = [[ProjectAppointmentsViewController alloc] initWithNibName:@"ProjectAppointmentsView" bundle:nil];
			cont.project = project;
			[self.navigationController pushViewController:cont animated:YES];
			[cont release];
			break;
		}
		case 2: {
			if( indexPath.row == 0 ) {
				ProjectServicesViewController *cont = [[ProjectServicesViewController alloc] initWithNibName:@"ProjectServicesView" bundle:nil];
				cont.project = project;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			} else if( indexPath.row == 1 ) {
				ProjectProductsViewController *cont = [[ProjectProductsViewController alloc] initWithNibName:@"ProjectProductsView" bundle:nil];
				cont.project = project;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			} else if( indexPath.row == 2 ) {
				ProjectEstimatesViewController *cont = [[ProjectEstimatesViewController alloc] initWithNibName:@"ProjectEstimatesView" bundle:nil];
				cont.project = project;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			} else if( indexPath.row == 3 ) {
				ProjectPaymentsViewController *cont = [[ProjectPaymentsViewController alloc] initWithNibName:@"ProjectPaymentsView" bundle:nil];
				cont.project = project;
				[self.navigationController pushViewController:cont animated:YES];
				[cont release];
			}
			break;
		}
	}
}

@end
