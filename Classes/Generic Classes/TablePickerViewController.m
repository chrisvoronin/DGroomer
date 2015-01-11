//
//  TablePickerViewController.m
//  myBusiness
//
//  Created by David J. Maier on 12/4/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//

#import "TablePickerViewController.h"


@implementation TablePickerViewController

@synthesize pickerDelegate, pickerValues, selectedValue, tblItems;

- (void) viewDidLoad {
	//
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.pickerValues = nil;
	self.selectedValue = nil;
	self.tblItems = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return pickerValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = @"TablePickerCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	NSString *value = [pickerValues objectAtIndex:indexPath.row];
	cell.textLabel.text = value;
	if( [value isEqualToString:selectedValue] || selectedRow == indexPath ) {
		if( !selectedRow ) {
			selectedRow = [indexPath retain];
		}
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	// Deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Report back
	[pickerDelegate selectionMadeWithString:[pickerValues objectAtIndex:indexPath.row]];
}


@end
