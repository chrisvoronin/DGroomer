//
//  PSAViewController.m
//  myBusiness
//
//  Created by David J. Maier on 6/8/09.
//  Modified by David J. Maier on 10/09.
//  Copyright SalonTechnologies, Inc. 2009. All rights reserved.
//

#import "Client.h"
#import "ClientTableViewController.h"
#import "ProductsTableViewController.h"
#import "ProjectsTableViewController.h"
#import "PSAAboutViewController.h"
#import "PSAAppDelegate.h"
#import "RegisterViewController.h"
#import "ReportsMenuViewController.h"
#import "ScheduleViewController.h"
#import "ServicesTableViewController.h"
#import "Settings.h"
#import "SettingsViewController.h"
#import "PSAViewController.h"
#import "ActivateAccountViewController.h"


@implementation PSAViewController

@synthesize btnInfo, btnProjects, btnClients, btnSchedule, btnRegister, btnServices, btnProducts, btnReports, btnSettings, btnContact, btnFreeCardReader;

- (void) viewDidLoad {
	self.title = @"Back";
	// Nav Bar Logo
	UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_first.png"]];
	self.navigationItem.titleView = title;
	[title release];
	
	// For Default.png grabbing
	/*
	btnInfo.hidden = YES;
	btnClients.hidden = YES;
	btnProjects.hidden = YES;
	btnProducts.hidden = YES;
	btnSchedule.hidden = YES;
	btnReports.hidden = YES;
	btnRegister.hidden = YES;
	btnServices.hidden = YES;
	btnSettings.hidden = YES;
	*/
	//
	[super viewDidLoad];
    CGRect scrollViewCRect  = self.view.bounds;
    scrollViewCRect.origin.y = 20;
    scrollViewCRect.size.height -= 20;
    [self.containerView setFrame:scrollViewCRect];
    [self.containerView setContentSize:CGSizeMake(320, 568)];
}

- (void) viewWillAppear:(BOOL)animated {
#ifdef PROJECT_NOT_INCLUDED
	[self layoutButtonsWithoutProjects];
#endif
    btnInfo.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}
- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	//DebugLog( @"PSAViewController didReceiveMemoryWarning" );
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
	self.btnInfo = nil;
	self.btnProjects = nil;
	self.btnClients = nil;
	self.btnSchedule = nil;
	self.btnRegister = nil;
	self.btnServices = nil;
	self.btnProducts = nil;
	self.btnReports = nil;
	self.btnSettings = nil;
    [self.btnFreeCardReader release];
    [self.btnContact release];
    [_containerView release];
    [super dealloc];
}

- (void) layoutButtonsWithoutProjects {
	btnProjects.hidden = YES;
	btnClients.frame = CGRectMake( 20, btnProjects.frame.origin.y + 64, 280, 40);
	btnSchedule.frame = CGRectMake( 20, 5+40+10 + 64, 280, 40);
	btnRegister.frame = CGRectMake( 20, 5+40*2+10*2 + 64, 280, 40);
	btnServices.frame = CGRectMake( 20, 5+40*3+10*3 + 64, 280, 40);
	btnProducts.frame = CGRectMake( 20, 5+40*4+10*4 + 64, 280, 40);
	btnReports.frame = CGRectMake( 20, 5+40*5+10*5 + 64, 280, 40);
	btnSettings.frame = CGRectMake( 20, 5+40*6+10*6 + 64, 280, 40);
    /*btnFreeCardReader.frame = CGRectMake( 20, 5+40*7+10*7 + 64, 280, 40);
	btnContact.frame = CGRectMake( 20, 5+40*8+10*8 + 64, 280, 40);*/
    
    btnContact.frame = CGRectMake( 20, 5+40*7+10*7 + 64, 280, 40);
	btnFreeCardReader.frame = CGRectMake( 20, 5+40*8+10*8 + 64, 280, 40);
    btnFreeCardReader.hidden = YES;
    
}

#pragma mark -
#pragma mark Action Methods
#pragma mark -

- (IBAction) scheduleB:(id)sender {
	ScheduleViewController *scheduleControl = [[ScheduleViewController alloc] initWithNibName:@"ScheduleView" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:scheduleControl animated:YES];
	[scheduleControl release];
}

- (IBAction) clientsB:(id)sender {
	ClientTableViewController *clientControl = [[ClientTableViewController alloc] initWithNibName:@"ClientTableView" bundle:nil];
	clientControl.showBirthdayAnniversarySegment = YES;
	[self.navigationController pushViewController:clientControl animated:YES];
	[clientControl release];
}

- (IBAction) formulateB:(id)sender {
	ProjectsTableViewController *projectsControl = [[ProjectsTableViewController alloc] initWithNibName:@"ProjectsTableView" bundle:nil];
	[self.navigationController pushViewController:projectsControl animated:YES];
	[projectsControl release];
}

- (IBAction) registerB:(id)sender {
	RegisterViewController *registerControl = [[RegisterViewController alloc] initWithNibName:@"RegisterView" bundle:nil];
	[self.navigationController pushViewController:registerControl animated:YES];
	[registerControl release];
}

- (IBAction) reportsB:(id)sender {
	ReportsMenuViewController *reportsControl = [[ReportsMenuViewController alloc] initWithNibName:@"ReportsMenuView" bundle:nil];
	[self.navigationController pushViewController:reportsControl animated:YES];
	[reportsControl release];
}

- (IBAction) settingsB:(id)sender {
	SettingsViewController *settingsControl = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
	[self.navigationController pushViewController:settingsControl animated:YES];
	[settingsControl release];
}

- (IBAction) productsB:(id)sender {
	ProductsTableViewController *productVC = [[ProductsTableViewController alloc] initWithNibName:@"ProductsTableView" bundle:nil];
	[self.navigationController pushViewController:productVC animated:YES];
	[productVC release];
}

- (IBAction) servicesB:(id)sender {	
	ServicesTableViewController *serviceControl = [[ServicesTableViewController alloc] initWithNibName:@"ServicesTableView" bundle:nil];
	[self.navigationController pushViewController:serviceControl animated:YES];
	[serviceControl release];
}

- (IBAction) getInfo:(id)sender {
	// Load the flipside view and animate it
	[self toggleView:nil];
}


- (void) toggleView:(id)sender {
	// This method is called when either of the subviews send a delegate message to us.
	// It flips the displayed view from the whoever sent the message to the other.
	if( aboutController == nil ) {
		aboutController = [[PSAAboutViewController alloc] initWithNibName:@"AboutPSAView" bundle:nil];
		aboutController.flipDelegate = self;
	}
	
	UIView *mainView = self.view;
	UIView *aboutView = aboutController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ( [self.view.subviews objectAtIndex:self.view.subviews.count-1] != aboutView ) {
		/*[aboutController viewWillAppear:YES];
		[self viewWillDisappear:YES];
		[self.view addSubview:aboutView];
		self.navigationController.navigationBarHidden = NO;
		[self viewDidDisappear:YES];
		[aboutController viewDidAppear:YES];
        ProductsTableViewController *productVC = [[ProductsTableViewController alloc] initWithNibName:@"ProductsTableView" bundle:nil];*/
        [self.navigationController pushViewController:aboutController animated:YES];
        //[aboutController release];
	} else {
		/*[self viewWillAppear:YES];
		[aboutController viewWillDisappear:YES];
		//self.navigationController.navigationBarHidden = NO;
		[aboutView removeFromSuperview];
		//[self.view addSubview:mainView];
		[aboutController viewDidDisappear:YES];
		[self viewDidAppear:YES];*/
        
		//[aboutController release];
		//aboutController = nil;
	}
	[UIView commitAnimations];
}
- (IBAction)signupFlow:(id)sender {
    ActivateAccountViewController * activeControl = [[ActivateAccountViewController alloc]initWithNibName:@"ActivateAccountViewController" bundle:nil];
    [self.navigationController pushViewController:activeControl animated:YES];
}

- (IBAction)contactBtnTapped:(id)sender {
    
    [self toggleView:nil];
    return;

    NSString *email = [[NSString alloc] initWithFormat:@"mailto:%@?subject=%@%@Support%@Ticket", @"support@merchantaccountsolutions.com", [APPLICATION_NAME stringByReplacingOccurrencesOfString:@" " withString:@"%20"], @"%20", @"%20"];
	//DebugLog(@"%@", email );
	NSURL *url = [[NSURL alloc] initWithString:email];
	[email release];
	[[UIApplication sharedApplication] openURL:url];
	[url release];
}

- (void)viewDidUnload {
    [self setBtnFreeCardReader:nil];
    [self setBtnContact:nil];
    [self setContainerView:nil];
    [super viewDidUnload];
}
@end
