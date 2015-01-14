//
//  ActivateAccountViewController.m
//  Cheap CCP
//
//  Created by JiangJian on 1/3/14.
//
//

#import "ActivateAccountViewController.h"
#import "ValidationUtility.h"
#import "SVProgressHUD.h"
#import "PSAAppDelegate.h"
#import "XMLReader.h"
#import "NBPhoneNumberUtil.h"
#import "CustomInsetTextField.h"
//#import "DeviceMgr.h"
//#import "ApplicationStateManager.h"
#import "NewBusinessInfoViewController.h"

@interface ActivateAccountViewController () {
    UITextField *activeField;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


@property (nonatomic, retain) ValidationUtility *validation;

@property (retain, nonatomic) IBOutlet UIView *m_contentView;

@end

@implementation ActivateAccountViewController

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"ACTIVATE ACCOUNT";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES];

    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor colorWithRed:12/255.0 green:138/255.0 blue:235/255.0 alpha:1.0],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:22.0f]
                                                            }];
    //[((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:self.m_contentView.frame.size];

    // for dismiss keyboard
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    //tapScroll.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapScroll];
}

- (void) tapped {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [scrollView release];
    [_m_contentView release];

    
    [super dealloc];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Set Validation Rules
- (void) initValues {
    
}

- (IBAction)onClick_btnNext:(id)sender {
//    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
//    if (isValid) {
//        NewBusinessInfoViewController *viewCtrl = [[NewBusinessInfoViewController alloc] initWithBusinessName:self.businessNameTextField.text merchantKey:0 phone:self.phoneNumTextField.text];
//        [self.navigationController pushViewController:viewCtrl animated:YES];
//    }
    
    [self.view endEditing:YES];
    NewBusinessInfoViewController *viewCtrl = [[NewBusinessInfoViewController alloc] initWithNibName:@"NewBusinessInfoViewController" bundle:nil];

    [self.navigationController pushViewController:viewCtrl animated:YES];
}
/*
#pragma mark - Network Connection

- (void)sendRequest
{
    NSString *serverAddress = @"https://www.icsleads.com/Api/AddLead/";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"POST"];
    NSString *testParam = [NSString stringWithFormat:@"originator=1029&source=CCCP&businessName=%@&contactName=%@&phone=%@&email=%@&returnType=xml", self.businessNameTextField.text, self.nameTextField.text, self.phoneNumTextField.text, self.emailTextField.text];
    
    NSData *postData = [testParam dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *requestError;
    NSError *parseError = nil;
    NSHTTPURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString *myString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:myString error:&parseError];
    self.strLeanId = [[[xmlDictionary objectForKey:@"ApiResponse"] objectForKey:@"LeadId"] objectForKey:@"text"];
}*/

@end
