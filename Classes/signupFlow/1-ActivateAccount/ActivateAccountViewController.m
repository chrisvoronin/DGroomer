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
@property (retain, nonatomic) IBOutlet CustomInsetTextField *nameTextField;
@property (retain, nonatomic) IBOutlet CustomInsetTextField *businessNameTextField;
@property (retain, nonatomic) IBOutlet CustomInsetTextField *emailTextField;
@property (retain, nonatomic) IBOutlet CustomInsetTextField *phoneNumTextField;
@property (retain, nonatomic) IBOutlet CustomInsetTextField *passwordTextField;
@property (retain, nonatomic) IBOutlet CustomInsetTextField *verifyPassTextField;
@property (retain, nonatomic) NSString *strLeanId;

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
        self.title = @"Activate Account";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //[((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:self.m_contentView.frame.size];
    
    // init values
    [self initValues];
    
    // init validation
    [self initValidations];
    
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
    [_nameTextField release];
    [_businessNameTextField release];
    [_emailTextField release];
    [_phoneNumTextField release];
    [_passwordTextField release];
    [_verifyPassTextField release];
    
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

- (void)initValidations {
    
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Validation"
                                                             andTitle:@"Warning"
                                                        andValidColor:[UIColor blackColor]
                                                     andNotValidColor:[UIColor redColor]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.nameTextField
                                           andValidationType:ValidationEmpty] autorelease]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.businessNameTextField
                                           andValidationType:ValidationMinLength andLength:4] autorelease]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.emailTextField
                                           andValidationType:ValidationEmail] autorelease]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.phoneNumTextField
                                           andValidationType:ValidationPhone] autorelease]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.passwordTextField
                                           andValidationType:ValidationMinLength andLength:4] autorelease]];
    
    [self.validation addValidationModel: [[[ValidationModel alloc]
                                           initWithField:self.verifyPassTextField
                                           mustMatch:self.passwordTextField] autorelease]];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    CGRect textFieldRect = [self.m_contentView convertRect:CGRectZero fromView:textField];
    int delta = textFieldRect.origin.y + 65 + 100 - self.view.frame.size.height + 216;
    if (delta < 0) {
        delta = 0;
    }
    [self.scrollView  setContentOffset:CGPointMake(0, delta) animated:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.nameTextField) {
        [self.businessNameTextField becomeFirstResponder];
        
    } else if (textField == self.businessNameTextField) {
        [self.emailTextField becomeFirstResponder];
        
    } else if (textField == self.emailTextField) {
        [self.phoneNumTextField becomeFirstResponder];
        
    } else if (textField == self.phoneNumTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    } else if (textField == self.passwordTextField) {
        [self.verifyPassTextField becomeFirstResponder];
    }else if (textField == self.verifyPassTextField) {
        [self onClick_btnNext:nil];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

#pragma mark - Actions

- (IBAction)onClick_btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClick_btnNext:(id)sender {
//    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
//    if (isValid) {
//        NewBusinessInfoViewController *viewCtrl = [[NewBusinessInfoViewController alloc] initWithBusinessName:self.businessNameTextField.text merchantKey:0 phone:self.phoneNumTextField.text];
//        [self.navigationController pushViewController:viewCtrl animated:YES];
//    }
    
    [self.view endEditing:YES];
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    if (isValid) {
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSError *aError = nil;
        NBPhoneNumber *myNumber = [phoneUtil parse:self.phoneNumTextField.text defaultRegion:@"US" error:&aError];
        
        NSString *validPhoneNumberString;
        if (aError == nil) {
            validPhoneNumberString = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatNATIONAL
                                                 error:&aError];
            
            self.phoneNumTextField.text = validPhoneNumberString;
        } else {
            validPhoneNumberString = self.phoneNumTextField.text;
        }
        
        [SVProgressHUD showWithStatus:@"Processing" maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Sucessfully Sent!"];

#if 0
                Cheap_CCPAppDelegate *appDelegate = (Cheap_CCPAppDelegate*)[UIApplication sharedApplication].delegate;
                
                appDelegate.strLeanID = [NSString stringWithFormat:@"%@", self.strLeanId];
                
                [appDelegate showMainTabCtrlView:YES tabIndex:1];
#else
                NewBusinessInfoViewController *viewCtrl = [[NewBusinessInfoViewController alloc] initWithBusinessName:self.businessNameTextField.text merchantKey:0 phone:self.phoneNumTextField.text];
                [self.navigationController pushViewController:viewCtrl animated:YES];
#endif
            });
        });
    }
}

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
}

@end
