//
//  NewBusinessInfoViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "NewBusinessInfoViewController.h"
//#import "Cheap_CCPAppDelegate.h"
#import "DataRegister.h"
#import "ConfigurationUtility.h"
#import "DLRadioButton.h"
@interface NewBusinessInfoViewController ()
{
    NSArray * stateNames;
    NSArray * ownershipTypes;
    
    NSString * businessName;
    long merchantKey;
    NSString * phoneNumber;
    BOOL	hasFedTax;
}
@property (retain, nonatomic) IBOutlet UIView *viewTaxField;

@property (retain, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (retain, nonatomic) IBOutlet UITextField *txtAddress;
@property (retain, nonatomic) IBOutlet UITextField *txtCity;
@property (retain, nonatomic) IBOutlet UITextField *txtState;
@property (retain, nonatomic) IBOutlet UIButton *btnState;
@property (retain, nonatomic) IBOutlet UITextField *txtZipCode;
@property (retain, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (retain, nonatomic) IBOutlet UITextField *txtFedralTaxId;
@property (retain, nonatomic) IBOutlet UITextField *txtOwnershipType;

@property (retain, nonatomic) IBOutlet UILabel    *lblPlaceHolderForTextView;
@property (retain, nonatomic) IBOutlet UITextView *txtViewProductsAndService;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutletCollection(DLRadioButton) NSArray *topRadioButtons;

@end

@implementation NewBusinessInfoViewController

@synthesize scrollView;

- (id) initWithBusinessName:(NSString *)bussName merchantKey:(long)mKey phone:(NSString *)phone {
    self = [self initWithNibName:@"NewBusinessInfoViewController" bundle:nil];
    if (self) {
        businessName = [[NSString stringWithString:bussName] retain];
        merchantKey = mKey;
        phoneNumber = [[NSString stringWithString:phone] retain];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Business Info";
        //creating state array
        stateNames = [[NSArray arrayWithObjects:@"AK", @"AL", @"AR", @"AZ", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"IA", @"ID", @"IL", @"IN", @"KS", @"KY", @"LA", @"MA", @"MD", @"ME", @"MI", @"MN", @"MO", @"MS", @"MT", @"NC", @"ND", @"NE", @"NH", @"NJ", @"NM", @"NV", @"NY", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VA", @"VT", @"WA", @"WI", @"WV", @"WY", nil] retain];
        
        //creating ownership types array
        ownershipTypes = [[NSArray arrayWithObjects:@"Sole Proprietor",@"LLC",@"Corporation",@"Non Profit", nil] retain];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self initValidations];
    
    self.txtBusinessName.text = businessName;
    self.txtPhoneNumber.text = phoneNumber;
    hasFedTax = YES;
    // set up button icons
    /*for (DLRadioButton *radioButton in self.topRadioButtons) {
        radioButton.ButtonIcon = [UIImage imageNamed:@"RadioButton"];
        radioButton.ButtonIconSelected = [UIImage imageNamed:@"RadioButtonSelected"];
    }
*/
}

- (void) initValidations {
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor darkGrayColor] andNotValidColor:[UIColor redColor]];
    
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtAddress andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtCity andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtZipCode andValidationType:ValidationZipCode]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtViewProductsAndService andValidationType:ValidationEmpty]];
    //[self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtFedralTaxId andValidationType:ValidationExactLength andLength:9]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtOwnershipType andValidationType:ValidationEmpty]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    //[((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}
- (IBAction)btnClick_yes:(id)sender {
    hasFedTax = YES;
    //self.txtFedralTaxId.hidden = NO;
    self.viewTaxField.hidden = NO;
}
- (IBAction)btnClick_no:(id)sender {
    hasFedTax = NO;
    //self.txtFedralTaxId.hidden = YES;
    self.viewTaxField.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_txtBusinessName release];
    [_txtAddress release];
    [_txtCity release];
    [_txtZipCode release];
    [_txtPhoneNumber release];
    [_txtViewProductsAndService release];
    [_txtFedralTaxId release];
    [_txtOwnershipType release];
    
    //[_scrollView release];
    [_contentView release];
    
    [_contentView release];
    [_viewTaxField release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Text Editing Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.contentView convertRect:CGRectZero fromView:textField];
    int delta = textFieldRect.origin.y + 65 + 100 - self.view.frame.size.height + 216;
    if (delta < 0) {
        delta = 0;
    }
    [self.scrollView  setContentOffset:CGPointMake(0, delta) animated:YES];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == self.txtAddress) {
        [self.txtCity becomeFirstResponder];
    
    } else if (textField == self.txtCity) {
        [textField resignFirstResponder];
    
    } else if (textField == self.txtZipCode) {
        [self.txtViewProductsAndService becomeFirstResponder];
    
    } else if (textField == self.txtFedralTaxId) {
        [self onClick_btnNext:Nil];
    }
    return NO;
}


/*
 * hide/show placeholder of TextView
 */
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.txtViewProductsAndService) {
        if ([text length] > 0) {
            self.lblPlaceHolderForTextView.hidden = YES;
        } else {
            if ([textView.text length] <= 1) {
                self.lblPlaceHolderForTextView.hidden = NO;
            } else {
                self.lblPlaceHolderForTextView.hidden = YES;
            }
        }
    }
    return YES;
}
- (IBAction)editDidEnd:(id)sender {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.txtFedralTaxId)
    {
        if(range.location >= 9)
        {
            //[self btnOwnershipClicked:Nil];
            return NO;
        }
    }
    if(textField == self.txtZipCode)
    {
        if(range.location >= 5)
        {
            return NO;
        }
    }
    return YES;
}
/*
 * dismiss keyboard
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
    [super touchesBegan:touches withEvent:event];
}

- (void) dismissKeyboard {
    [self.txtBusinessName resignFirstResponder];
    [self.txtAddress resignFirstResponder];
    [self.txtCity resignFirstResponder];
    [self.txtZipCode resignFirstResponder];
    [self.txtPhoneNumber resignFirstResponder];
    [self.txtFedralTaxId resignFirstResponder];
    [self.txtOwnershipType resignFirstResponder];
    [self.txtViewProductsAndService resignFirstResponder];
}


#pragma mark - Actions

- (IBAction)btnStateClicked:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"AK", @"AL", @"AR", @"AZ", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"IA", @"ID", @"IL", @"IN", @"KS", @"KY", @"LA", @"MA", @"MD", @"ME", @"MI", @"MN", @"MO", @"MS", @"MT", @"NC", @"ND", @"NE", @"NH", @"NJ", @"NM", @"NV", @"NY", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VA", @"VT", @"WA", @"WI", @"WV", @"WY", nil];
    [actionSheet setTag:0];
    [actionSheet showInView:self.view.window];
}

- (IBAction)btnOwnershipClicked:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Sole-Proprietor", @"LLC", @"Corporation", @"Non-Profit", nil];
    [actionSheet setTag:1];
    [actionSheet showInView:self.view.window];
}

- (void) actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 0: {
            if (buttonIndex >= 0 && buttonIndex < [stateNames count]) {
                _txtState.text = [stateNames objectAtIndex:buttonIndex];
            }
        }
        break;
        
        case 1: {
            if (buttonIndex >= 0 && buttonIndex < [ownershipTypes count]) {
                _txtOwnershipType.text = [ownershipTypes objectAtIndex:buttonIndex];
            }
        }
        break;
    }
}

- (IBAction)onClick_btnNext:(id)sender {
    NSString * federalTaxID = self.txtFedralTaxId.isHidden ? @"" : self.txtFedralTaxId.text;
    if(federalTaxID.length != 9 && hasFedTax){
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Please input 9 digits long tax id." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    // data submit
    [[DataRegister instance] getBussinessItem].businessName = self.txtBusinessName.text;
    [[DataRegister instance] getBussinessItem].addressModel.address = self.txtAddress.text;
    [[DataRegister instance] getBussinessItem].addressModel.city = self.txtCity.text;
    [[DataRegister instance] getBussinessItem].addressModel.state = self.txtState.text;
    [[DataRegister instance] getBussinessItem].addressModel.zip = self.txtZipCode.text;
    [[DataRegister instance] getBussinessItem].phone = self.txtPhoneNumber.text;
    
    [[DataRegister instance] getBussinessItem].federalTaxID = federalTaxID;
    [self submitForm];
}

#pragma mark - Form Submission
/*
 request code:
 
 {
    "rqd": {
        "ad": "Mike",
        "ci": "Doe",
        "st": "Doe Bakery",
        "zp": "abc@abc.net",
        "pn": "123-456-9870",
        "desc": "1111", "ftx":"Fed Tax","owt":1
    },
    "sd": {
        "mid": 123,
        "uem": "user@abc.net",
        "uid": 987,
        "ldk": "Mobile123"
    }
 }
 */
-(void)progressTask
{
    NewPrincipalInfoViewController *viewctrl = [[NewPrincipalInfoViewController alloc] initWithAddress:self.txtAddress.text city:self.txtCity.text state:self.txtState.text zip:self.txtZipCode.text merchantKey:merchantKey];
    [self.navigationController pushViewController:viewctrl animated:YES];
    return;
    
    
    int indexOwnership = [ownershipTypes indexOfObject:self.txtOwnershipType.text];
    
    NSDictionary * dict = @{
                            @"bn" : [[DataRegister instance] getBussinessItem].businessName,
                           /* @"ad" : [[DataRegister instance] getBussinessItem].addressModel.address,*/
                            @"ci" : [[DataRegister instance] getBussinessItem].addressModel.city,
                            @"st" : [[DataRegister instance] getBussinessItem].addressModel.state,
                            @"zp" : [[DataRegister instance] getBussinessItem].addressModel.zip,
                            @"pn" : [[DataRegister instance] getBussinessItem].phone,
                            @"desc" : self.txtViewProductsAndService.text,
                            @"ftx" : [[DataRegister instance] getBussinessItem].federalTaxID,
                            @"owt" : [NSNumber numberWithInt:indexOwnership]
                            };
    
    self.dal = [[ServiceDAL alloc] initWiThPostData:dict urlString:URL_MERCHANT_BUSINESSINFO delegate:self];
    [self.dal startAsync];
}

-(void)handleServiceResponseWithDict:(NSDictionary*)dictionary
{
    if([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_BUSINESSINFO]){
        /// new account success
    }
    
    NewPrincipalInfoViewController *viewctrl = [[NewPrincipalInfoViewController alloc] initWithAddress:self.txtAddress.text city:self.txtCity.text state:self.txtState.text zip:self.txtZipCode.text merchantKey:merchantKey];
    [self.navigationController pushViewController:viewctrl animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
