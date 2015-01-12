//
//  AppointmentNotesViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/19/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Appointment.h"
#import "AppointmentNotesViewController.h"

@implementation AppointmentNotesViewController

@synthesize appointment, isEditable, tblNotes, txtNotes;


- (void) viewDidLoad {
	self.title = @"Notes";
	//
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundGray.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[tblNotes setBackgroundColor:bgColor];
	[bgColor release];*/
	// Create the UITextView
	txtNotes = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 140)];
	txtNotes.font = [UIFont systemFontOfSize:16];
	if( isEditable ) {
		// Done Button
		UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		self.navigationItem.rightBarButtonItem = btnDone;
		[btnDone release];
	}
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	if( appointment ) {
		txtNotes.text = appointment.notes;
	}
	if( isEditable ) {
		[txtNotes becomeFirstResponder];
	} else {
		txtNotes.editable = NO;
	}
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	[txtNotes release];
	self.tblNotes = nil;
	[appointment release];
    [super dealloc];
}

- (void) done {
	[txtNotes resignFirstResponder];
	if( appointment != nil ) {
		if( txtNotes ) {
			appointment.notes = txtNotes.text;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -
/*
 *	1 section for each instruction:
 *	Parameters, step1Instructions, step1, step2, refreshing options, foils
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

/*
 *	Just the 1 row for the textView
 */
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 160;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"NotesID";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
    }

	if( txtNotes ) {
		[cell.contentView addSubview:txtNotes];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
