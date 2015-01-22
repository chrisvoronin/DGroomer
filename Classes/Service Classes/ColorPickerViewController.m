//
//  ColorPickerViewController.m
//  myBusiness
//
//  Created by David J. Maier on 11/17/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Service.h"
#import "ColorPickerViewController.h"


@implementation ColorPickerViewController

@synthesize picker, service, m_colorSelected;


- (void) viewDidLoad {
	self.title = @"COLOR";
	// Set the background color to a nice blue image
	/*UIImage *bg = [UIImage imageNamed:@"pinstripeBackgroundPurple.png"];
	UIColor *bgColor = [[UIColor alloc] initWithPatternImage:bg];
	[self.view setBackgroundColor:bgColor];
	[bgColor release];*/
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	// Colors
	colors = [[NSArray alloc] initWithObjects:
												[UIColor colorWithRed:1 green:.8 blue:.4 alpha:.7],	// Canteloupe
												[UIColor colorWithRed:1 green:.5 blue:0 alpha:.7],	// Orange
												[UIColor colorWithRed:.6 green:.4 blue:.2 alpha:.7],	// Brown
			  
												[UIColor colorWithRed:1 green:.67 blue:.81 alpha:.7],	// Pink
												[UIColor colorWithRed:1 green:.44 blue:.81 alpha:.7],	// Carnation
												[UIColor colorWithRed:1 green:0 blue:1 alpha:.7],		// Magenta
												[UIColor colorWithRed:1 green:0 blue:0 alpha:.7],		// Red
												[UIColor colorWithRed:.78 green:.64 blue:.78 alpha:.7],	// Lilac
												[UIColor colorWithRed:.5 green:0 blue:.5 alpha:.7],		// Purple
			  
												[UIColor colorWithRed:.4 green:.8 blue:1 alpha:.7],	// Sky
												[UIColor colorWithRed:0 green:1 blue:1 alpha:.7],	// Cyan
												[UIColor colorWithRed:0 green:0 blue:1 alpha:.7],	// Blue
												[UIColor colorWithRed:0 green:.25 blue:.5 alpha:.7],	// Ocean
												[UIColor colorWithRed:0 green:0 blue:.5 alpha:.7],	// Midnight
												
												[UIColor colorWithRed:.8 green:1 blue:.4 alpha:.7],	// Honeydew
												[UIColor colorWithRed:.5 green:1 blue:0 alpha:.7],	// Lime
												[UIColor colorWithRed:0 green:1 blue:0 alpha:.7],	// Green
												[UIColor colorWithRed:0 green:.5 blue:0 alpha:.7],	// Clover
			  
												[UIColor colorWithRed:1 green:1 blue:.4 alpha:.7],	// Banana
												[UIColor colorWithRed:1 green:1 blue:0 alpha:.7],	// Yellow
												[UIColor colorWithRed:.5 green:.5 blue:0 alpha:.7],	// Asparagus
												
												[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.7],	// Mercury
												[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:.7],	// Silver
												[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:.7],	// Aluminum
												[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.7],	// Nickel
												[UIColor colorWithRed:0 green:0 blue:0 alpha:.7], nil];
	//
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {

}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
- (IBAction)onSelectedColor:(id)sender {
    int tag = ((UIButton*)sender).tag;
    //    self.m_colorSelected = tag == 0 ? nil : ((UIButton*)sender).backgroundColor;//[self imageWithColor:((UIButton*)sender).backgroundColor size:((UIButton*)sender).frame.size];
    UIColor *selectedColor = ((UIButton*)sender).backgroundColor;
    const CGFloat *c = CGColorGetComponents(selectedColor.CGColor);
    self.m_colorSelected = [[NSString alloc] initWithFormat:@"%f::%f::%f", c[0], c[1], c[2]];
    
    //self.m_colorSelected = tag;
    
    UIButton * selectButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 70, 20, 20)];
    [selectButton setBackgroundImage:[UIImage imageNamed:@"chkbox_checked.png"] forState:UIControlStateNormal];
    [((UIButton*)sender) addSubview:selectButton];
    
    for(UIView * subView in self.m_buttonContainer.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            int curTag = ((UIButton*)subView).tag;
            if(curTag != tag)
            {
                for(UIView * subViewButton in subView.subviews)
                {
                    if([subViewButton isKindOfClass:[UIButton class]])
                    {
                        [subViewButton removeFromSuperview];
                    }
                }
            }
        }
    }
}

- (void) dealloc {
	[colors release];
	[service release];
    [_m_buttonContainer release];
    [m_colorSelected release];
    [super dealloc];
}

- (void) done {
	[service setColorWithString:m_colorSelected];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIPickerView Delegate and DataSource Methods
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return colors.count;
}

// Called by the picker view when it needs the view to use for a given row in a given component.
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	if( !view ) {
		view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)] autorelease];
	}
	view.backgroundColor = [colors objectAtIndex:row];
	return view;
}

@end
