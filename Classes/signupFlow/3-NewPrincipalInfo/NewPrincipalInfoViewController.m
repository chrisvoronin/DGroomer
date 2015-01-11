//
//  NewPrincipalInfoViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "NewPrincipalInfoViewController.h"
#import "DataRegister.h"
#import "ConfigurationUtility.h"
//#import "Cheap_CCPAppDelegate.h"

@interface NewPrincipalInfoViewController ()
{
    NSArray * stateNames;
    long merchantKey;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIButton *btnCheckHomeAdd;
@property (retain, nonatomic) IBOutlet UITextField *txtAddress;
@property (retain, nonatomic) IBOutlet UITextField *txtCity;
@property (retain, nonatomic) IBOutlet UITextField *txtState;
@property (retain, nonatomic) IBOutlet UITextField *txtZipCode;
@property (retain, nonatomic) IBOutlet UITextField *txtDOB1;
@property (retain, nonatomic) IBOutlet UITextField *txtDOB2;
@property (retain, nonatomic) IBOutlet UITextField *txtDOB3;
@property (retain, nonatomic) IBOutlet UITextField *txtSSN1;
@property (retain, nonatomic) IBOutlet UITextField *txtSSN2;
@property (retain, nonatomic) IBOutlet UITextField *txtSSN3;


@property (nonatomic, strong) AddressModel *businessAddress;

@end

@implementation NewPrincipalInfoViewController

-(id)initWithAddress:(NSString*)bAddress city:(NSString*)bCity state:(NSString*)bState zip:(NSString*)bZip merchantKey:(long)mKey
{
    self = [self initWithNibName:@"NewPrincipalInfoViewController" bundle:nil];
    if (self)
    {
        self.businessAddress = [[AddressModel alloc] initWithAddress:bAddress city:bCity state:bState zip:bZip];
        merchantKey = mKey;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Principal Info";
        stateNames = [[NSArray arrayWithObjects:@"", @"AK",@"AL",@"AR",@"AZ",@"CA",@"CO",@"CT",@"DE",@"FL",@"GA",@"HI",@"IA",@"ID",@"IL",@"IN",@"KS",@"KY",@"LA",@"MA",@"MD",@"ME",@"MI",@"MN",@"MO",@"MS",@"MT",@"NC",@"ND",@"NE",@"NH",@"NJ",@"NM",@"NV",@"NY",@"OH",@"OK",@"OR",@"PA",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VA",@"VT",@"WA",@"WI",@"WV",@"WY", nil] retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self initValidations];
    
    //setup text from model.
    [self copyBusinessToFields];
}

- (void) initValidations {
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor darkGrayColor] andNotValidColor:[UIColor redColor]];
    
    //adding validation
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtAddress andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtCity andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtState andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtZipCode andValidationType:ValidationZipCode]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtDOB1 andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtDOB2 andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtDOB3 andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtSSN1 andValidationType:ValidationExactLength andLength:3]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtSSN2 andValidationType:ValidationExactLength andLength:2]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtSSN3 andValidationType:ValidationExactLength andLength:4]];
}

- (void)copyBusinessToFields {
    if (self.businessAddress) {
        self.txtAddress.text = self.businessAddress.address;
        self.txtCity.text = self.businessAddress.city;
        self.txtState.text = self.businessAddress.state;
        self.txtZipCode.text = self.businessAddress.zip;
    }
}

- (void) clearAddress {
    if ([self.txtAddress.text isEqualToString:self.businessAddress.address]) {
        self.txtAddress.text = @"";
        self.txtCity.text = @"";
        self.txtState.text = @"";
        self.txtZipCode.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.navigationController setNavigationBarHidden:YES];
    //[((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)dealloc {
    [_btnCheckHomeAdd release];
    [_scrollView release];
    [_contentView release];
    [super dealloc];
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.txtDOB1){
        if(range.location == 2){
            NSInteger integer = [self.txtDOB1.text integerValue];
            if(integer<1 || integer>31)
            {
                UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                       message:@"Enter date in 1~31."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                [obj_alertView show];
                [obj_alertView release];
                [self.txtDOB1 becomeFirstResponder];
                return NO;
            }
            [self.txtDOB2 setText:string];
            [self.txtDOB2 becomeFirstResponder];
            return NO;
        }
    }else if(textField == self.txtDOB2){
        if(range.location == 2){
            NSInteger integer = [self.txtDOB2.text integerValue];
            if(integer<1 || integer>12)
            {
                UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                       message:@"Enter month in 1~12."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                [obj_alertView show];
                [obj_alertView release];
                [self.txtDOB2 becomeFirstResponder];
                return NO;
            }
            [self.txtDOB3 setText:string];
            [self.txtDOB3 becomeFirstResponder];
            return NO;
        }
    }else if(textField == self.txtDOB3){
        if(range.location == 4){
            NSInteger integer = [self.txtDOB3.text integerValue];
            if(integer<1900 || integer>2100)
            {
                UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                       message:@"Enter year in 1900~2100."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                [obj_alertView show];
                [obj_alertView release];
                [self.txtDOB3 becomeFirstResponder];
                return NO;
            }
            [self.txtSSN1 becomeFirstResponder];
            return NO;
        }
    }
    else if(textField == self.txtSSN1){
        if(range.location == 3){
            [self.txtSSN2 setText:string];
            [self.txtSSN2 becomeFirstResponder];
            return NO;
        }
    }
    else if(textField == self.txtSSN2){
        if(range.location == 2){
            [self.txtSSN3 setText:string];
            [self.txtSSN3 becomeFirstResponder];
            return NO;
        }
    }
    else if(textField == self.txtSSN3){
        if(range.location == 4){
            return NO;
        }
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == self.txtAddress) {
        [self.txtCity becomeFirstResponder];
    } else if (textField == self.txtCity) {
        [self.txtZipCode becomeFirstResponder];
    } else if (textField == self.txtZipCode) {
        [self.txtDOB1 becomeFirstResponder];
    } else if (textField == self.txtDOB1) {
        
        if(self.txtDOB1.text.length == 1){
            NSString * newString = [NSString stringWithFormat:@"0%@",self.txtDOB1.text];
            [self.txtDOB1 setText:newString];
        }
        [self.txtDOB2 becomeFirstResponder];
    } else if (textField == self.txtDOB2) {
        if(self.txtDOB2.text.length == 1){
            NSString * newString = [NSString stringWithFormat:@"0%@",self.txtDOB2.text];
            [self.txtDOB2 setText:newString];
        }
        [self.txtDOB3 becomeFirstResponder];
    } else if (textField == self.txtDOB3) {
        [self.txtSSN1 becomeFirstResponder];
    } else if (textField == self.txtSSN1) {
        [self.txtSSN2 becomeFirstResponder];
    } else if (textField == self.txtSSN2) {
        [self.txtSSN3 becomeFirstResponder];
    } else if (textField == self.txtSSN3) {
        [self onClick_btnNext:nil];
    }
    
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.txtDOB1) {
        NSInteger integer = [self.txtDOB1.text integerValue];
        if(integer<1 || integer>31)
        {
            UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"Enter date in 1~31."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [obj_alertView show];
            [obj_alertView release];
            [self.txtDOB1 becomeFirstResponder];
            return;
        }
        if(self.txtDOB1.text.length == 1){
            NSString * newString = [NSString stringWithFormat:@"0%@",self.txtDOB1.text];
            [self.txtDOB1 setText:newString];
        }
    }
    if (textField == self.txtDOB2) {
        NSInteger integer = [self.txtDOB2.text integerValue];
        if(integer<1 || integer>12)
        {
            UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"Enter month in 1~12."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [obj_alertView show];
            [obj_alertView release];
            [self.txtDOB2 becomeFirstResponder];
            return;
        }
        if(self.txtDOB2.text.length == 1){
            NSString * newString = [NSString stringWithFormat:@"0%@",self.txtDOB2.text];
            [self.txtDOB2 setText:newString];
        }
    }
    if (textField == self.txtDOB3) {
        NSInteger integer = [self.txtDOB3.text integerValue];
        if(integer<1900 || integer>2100)
        {
            UIAlertView *obj_alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:@"Enter year in 1980~2100."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [obj_alertView show];
            [obj_alertView release];
            [self.txtDOB3 becomeFirstResponder];
            return;
        }
    }
}
/*
 * dismiss keyboard
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
    [super touchesBegan:touches withEvent:event];
}

- (void) dismissKeyboard {
    [self.txtAddress resignFirstResponder];
    [self.txtCity resignFirstResponder];
    [self.txtState resignFirstResponder];
    [self.txtZipCode resignFirstResponder];
    [self.txtDOB1 resignFirstResponder];
    [self.txtDOB2 resignFirstResponder];
    [self.txtDOB3 resignFirstResponder];
    [self.txtDOB1 resignFirstResponder];
    [self.txtDOB2 resignFirstResponder];
    [self.txtDOB3 resignFirstResponder];
}

#pragma mark - Actions
- (IBAction)onCheckHome:(id)sender {
    [_btnCheckHomeAdd setSelected:![_btnCheckHomeAdd isSelected]];
    
    if (self.btnCheckHomeAdd.isSelected) {
        [self copyBusinessToFields];
    } else {
        [self clearAddress];
    }
}

- (IBAction)onClick_btnState:(id)sender {
    [self showCustomPickerView:stateNames selectedString:self.txtState.text target:self.txtState];
}

- (IBAction)onClick_btnNext:(id)sender {
    [[DataRegister instance] getPrincipalItem].Address = self.txtAddress.text;
    [[DataRegister instance] getPrincipalItem].Address2 = @"";
    [[DataRegister instance] getPrincipalItem].City = self.txtCity.text;
    [[DataRegister instance] getPrincipalItem].State = self.txtState.text;
    [[DataRegister instance] getPrincipalItem].Zip = self.txtZipCode.text;
    NSString *dob = [NSString stringWithFormat:@"%@/%@/%@", self.txtDOB1.text, self.txtDOB2.text, self.txtDOB3.text];
    //NSString *dob = @"02/24/2014";
    [[DataRegister instance] getPrincipalItem].DOB = dob;
    NSString *ssn = [NSString stringWithFormat:@"%@%@%@", self.txtSSN1.text, self.txtSSN2.text, self.txtSSN3.text];
    [[DataRegister instance] getPrincipalItem].SSN = ssn;
    
    [self submitForm];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Form Submission
/*
request code:
 
{
    "rqd": {
        "ad": "Mike",
        "ad2": "Doe",
        "ci": "Doe Bakery",
        "st": "abc@abc.net",
        "zp": "123-456-9870",
        "dob": "01/12/1956", "ssn":""
    },
    "sd": {
        "mid": 123,
        "uem": "user@abc.net",
        "uid": 987,
        "ldk": "Mobile123"
    }
}
*/
/*
 
 */
 
- (void) progressTask {
    
    NewAccountInfoViewController *vc = [[NewAccountInfoViewController alloc] initWithMerchantKey:merchantKey];
    [self.navigationController pushViewController:vc animated:YES];
    return;
    
    NSDictionary * dict = @ {
        @"ad" : [[DataRegister instance] getPrincipalItem].Address,
        @"ad2" : [[DataRegister instance] getPrincipalItem].Address2,
        @"ci" : [[DataRegister instance] getPrincipalItem].City,
        @"st" : [[DataRegister instance] getPrincipalItem].State,
        @"zp" : [[DataRegister instance] getPrincipalItem].Zip,
        @"dob" : [[DataRegister instance] getPrincipalItem].DOB,
        @"ssn" : [[DataRegister instance] getPrincipalItem].SSN
    };
    
    self.dal = [[ServiceDAL alloc] initWiThPostData:dict urlString:URL_MERCHANT_PRINCIPALINFO delegate:self];
    [self.dal startAsync];
}

-(void)handleServiceResponseWithDict:(NSDictionary *)dictionary {
    if ([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_PRINCIPALINFO]) {
        // New Account Success
    }
    
    NewAccountInfoViewController *vc = [[NewAccountInfoViewController alloc] initWithMerchantKey:merchantKey];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
