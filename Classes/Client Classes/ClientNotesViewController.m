//
//  ClientNotesViewController.m
//  myBusiness
//
//  Created by David J. Maier on 10/21/09.
//  Copyright 2009 SalonTechnologies, Inc.. All rights reserved.
//
#import "Client.h"
#import "PSADataManager.h"
#import "ClientNotesViewController.h"


@implementation ClientNotesViewController

@synthesize bbiSave, notesBackground, textView;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle { 
    self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) {
		self.title = @"Notes";
		self.tabBarItem.image = [UIImage imageNamed:@"iconNotes.png"];
    } 
    return self; 
} 

- (void) viewDidLoad {
	// Disable the save button until something changes
	bbiSave.enabled = NO;
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(bbiSaveTouchUp)];
    self.navigationItem.rightBarButtonItem = btnAdd;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = NO;
    
    
    [btnAdd release];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    [barButton release];
    
	[super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {

    //[self.view setUserInteractionEnabled:NO];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    [barButton release];
}

- (void) viewWillAppear:(BOOL)animated {
	textView.text = client.notes;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    [barButton release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	self.textView = nil;
	self.notesBackground = nil;
	self.bbiSave = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark UIResponder Methods
#pragma mark -
/*
 *	Get rid of the keyboard when the user touches outside the textView
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[textView resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark IBAction Methods
#pragma mark -
- (IBAction) bbiSaveTouchUp {
	client.notes = textView.text;
	[[PSADataManager sharedInstance] updateClient:client];
	bbiSave.enabled = NO;
	[textView resignFirstResponder];
    
    
}

#pragma mark -
#pragma mark UITextView Delegate Methods
#pragma mark -

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	bbiSave.enabled = YES;
	return YES;
}


@end
