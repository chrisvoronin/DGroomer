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
	// Done Button
	UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = btnDone;
	[btnDone release];
	// Colors
	colors = [[NSArray alloc] initWithObjects:
												[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1],
												[UIColor colorWithRed:1 green:.8 blue:.2 alpha:1],
												[UIColor colorWithRed:1 green:.6 blue:0 alpha:1],
			  
												[UIColor colorWithRed:1 green:.33 blue:.12 alpha:1],
												[UIColor colorWithRed:.89 green:0 blue:.11 alpha:1],
												[UIColor colorWithRed:.84 green:.18 blue:.39 alpha:1],
												[UIColor colorWithRed:.39 green:.18 blue:.44 alpha:1],
												[UIColor colorWithRed:.29 green:.15 blue:.58 alpha:1],
												[UIColor colorWithRed:.15 green:.27 blue:.69 alpha:1],
			  
												[UIColor colorWithRed:.15 green:.63 blue:.8 alpha:1],
												[UIColor colorWithRed:.13 green:.76 blue:.51 alpha:1],
												[UIColor colorWithRed:.09 green:.61 blue:.2 alpha:1],
												[UIColor colorWithRed:.36 green:.74 blue:.32 alpha:1],
												[UIColor colorWithRed:.84 green:.9 blue:.18 alpha:1],
                                                [UIColor colorWithRed:.85 green:.85 blue:.85 alpha:1], nil];
	//
    

    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    for(UIView * subView in self.m_buttonContainer.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            ((UIButton*)subView).backgroundColor = colors[((UIButton*)subView).tag];
        }
    }
    
    for(UIView * subView in self.m_buttonContainer.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            const CGFloat *clr0 = CGColorGetComponents(((UIButton*)subView).backgroundColor.CGColor);
            
            const CGFloat *clr1 = CGColorGetComponents(service.color.CGColor);
           
            CGFloat distance = sqrtf(powf((clr0[0] - clr1[0]), 2) + powf((clr0[1] - clr1[1]), 2) + powf((clr0[2] - clr1[2]), 2) );
            if(distance<=0.001){
                UIButton * selectButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 70, 20, 20)];
                [selectButton setBackgroundImage:[UIImage imageNamed:@"chkbox_checked.png"] forState:UIControlStateNormal];
                [((UIButton*)subView) addSubview:selectButton];
                
                self.m_colorSelected = [[NSString alloc] initWithFormat:@"%f::%f::%f", clr1[0], clr1[1], clr1[2]];
            }
            /*//if([((UIButton*)subView).backgroundColor isEqual:service.color])
            if(CGColorEqualToColor(((UIButton*)subView).backgroundColor.CGColor, service.color.CGColor))
            {
                UIButton * selectButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 70, 20, 20)];
                [selectButton setBackgroundImage:[UIImage imageNamed:@"chkbox_checked.png"] forState:UIControlStateNormal];
                [((UIButton*)subView) addSubview:selectButton];
            }*/
        }
    }

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
