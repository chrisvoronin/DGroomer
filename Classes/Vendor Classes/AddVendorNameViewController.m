

#import "AddVendorNameViewController.h"

@implementation AddVendorNameViewController

@synthesize contact;
//@synthesize contactController;
@synthesize appDelegate;

- (IBAction)cancelNames:(id)sender {
	[self.view removeFromSuperview];
}

- (IBAction)saveNames:(id)sender {
	/*
	//Write out data to database
	if (![contact.text isEqualToString:@""])
		appDelegate.contact = contact.text;
	
		[self.view removeFromSuperview];
	[contactController viewWillAppear: YES];
	 */
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// Use the delegate to set/get values
	appDelegate = (PSAAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Set the background color to a nice yelow image
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yellow_PSA.png"]];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[contact release];
//	[contactController release];
    [super dealloc];
}


@end
