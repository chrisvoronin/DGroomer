//
//  NewAccountInfoViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/25/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "NewAccountInfoViewController.h"
#import "PSAAppDelegate.h"
#import "BankInfo.h"
#import "DataRegister.h"
#import "ConfigurationUtility.h"

@interface NewAccountInfoViewController ()
{
    NSMutableArray * arrayAverageSales;
    NSMutableArray * arrayMonthlySales;
    long merchantKey;
    
    int curOffsetOfScrollView;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIButton *btnInPerson;
@property (retain, nonatomic) IBOutlet UIButton *btnNonPerson;
- (IBAction)onSelectPersonInfo:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *txtAverageSalePerCustomer;
@property (retain, nonatomic) IBOutlet UITextField *txtMonthlySales;

@property (retain, nonatomic) IBOutlet UITextField *txtBankName;
@property (retain, nonatomic) IBOutlet UITextField *txtBankRoutingName;
@property (retain, nonatomic) IBOutlet UITextField *txtBankAccountingNumber;

@property (retain, nonatomic) IBOutlet UIButton *chkBtnAgreeCheckMark;

@end

@implementation NewAccountInfoViewController

@synthesize scrollView;

-(id)initWithMerchantKey:(long)mKey
{
    self = [self initWithNibName:@"NewAccountInfoViewController" bundle:nil];
    if (self)
    {
        merchantKey = mKey;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Account Info";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //[((Cheap_CCPAppDelegate*) [[UIApplication sharedApplication] delegate]) showTabBar:NO];
    
    curOffsetOfScrollView = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.chkBtnAgreeCheckMark setSelected:NO];
    
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self initValidations];
    
    //filling out arrays (todo, stop silliness)
    arrayAverageSales = [[NSMutableArray alloc] init];
    for(int i = 0; i <= 100; i = i + 5) {
        
        NSString *value;
        if(i == 0) {
            value = [NSString stringWithFormat:@"$%d.00", i+1];
        } else {
            value = [NSString stringWithFormat:@"$%d.00", i];
        }
        [arrayAverageSales addObject:value];
    }
    
    for(int i = 150; i <= 1000; i = i + 50) {
        NSString *value;
        value = [NSString stringWithFormat:@"$%d.00", i];
        [arrayAverageSales addObject:value];
    }
    
    for(int i = 1500; i <= 5000; i = i + 500) {
        NSString *value;
        value = [NSString stringWithFormat:@"$%d.00", i];
        [arrayAverageSales addObject:value];
    }
    
    arrayMonthlySales = [[NSMutableArray alloc] init];
    
    for(int i = 500; i <= 25000; i = i + 500) {
        NSString *value;
        value = [NSString stringWithFormat:@"$%d.00", i];
        [arrayMonthlySales addObject:value];
    }
    
    for(int i = 30000; i <= 100000; i = i + 5000) {
        NSString *value;
        value = [NSString stringWithFormat:@"$%d.00", i];
        [arrayMonthlySales addObject:value];
    }
}

- (void) initValidations {
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Warning" andValidColor:[UIColor darkGrayColor] andNotValidColor:[UIColor redColor]];
    
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtAverageSalePerCustomer andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtMonthlySales andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtBankName andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtBankAccountingNumber andValidationType:ValidationNumbersOnly]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtBankRoutingName andValidationType:ValidationABA]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_txtBankName release];
    [_txtBankRoutingName release];
    [_txtBankAccountingNumber release];
    [_btnInPerson release];
    [_btnNonPerson release];
   
    [scrollView release];
    [_contentView release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - hide keboard when touch out of textfield
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
    [super touchesBegan:touches withEvent:event];
}

- (void) dismissKeyboard {
    [self.txtBankName resignFirstResponder];
    [self.txtBankRoutingName resignFirstResponder];
    [self.txtBankAccountingNumber resignFirstResponder];
    
}

#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.contentView convertRect:CGRectZero fromView:textField];
    int delta = textFieldRect.origin.y + 65 + 100 - self.view.frame.size.height + 216;
    curOffsetOfScrollView = delta;
    if (curOffsetOfScrollView < 0) {
        curOffsetOfScrollView = 0;
    }
    [self.scrollView  setContentOffset:CGPointMake(0, curOffsetOfScrollView) animated:YES];
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtBankName) {
        [self.txtBankRoutingName becomeFirstResponder];
        
    } else if (textField == self.txtBankRoutingName) {
        [self.txtAverageSalePerCustomer becomeFirstResponder];
        
    } else if (textField == self.txtAverageSalePerCustomer) {
        [self onClick_btnNext:nil];
    }
    
    return NO;
}


#pragma mark - Actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClick_btnAverageSalePerCustomer:(id)sender {
    // show uipicker
    [self showCustomPickerView:arrayAverageSales
                selectedString:self.txtAverageSalePerCustomer.text
                        target:self.txtAverageSalePerCustomer];
}

- (IBAction)onClick_btnMonthlySales:(id)sender {
    // show uipicker
    [self showCustomPickerView:arrayMonthlySales
                selectedString:self.txtMonthlySales.text
                        target:self.txtMonthlySales];
}

- (IBAction)onClickCheckMark:(id)sender {
    [self.chkBtnAgreeCheckMark setSelected:!self.chkBtnAgreeCheckMark.isSelected];
}

- (IBAction)onClick_btnInfoMark:(id)sender {
    [self.view_DepositFund setAlpha:0.f];
    [self.view addSubview:self.view_DepositFund];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view_DepositFund setAlpha:1.f];
    }];
}
- (IBAction)onClick_btnClose:(id)sender {
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view_DepositFund setAlpha:0.f];
    }];
    [self.view_DepositFund removeFromSuperview];
}

- (IBAction)onClick_btnNext:(id)sender {
    //TODO
//    [self handleServiceResponseWithDict:nil];
    
    if(!self.chkBtnAgreeCheckMark.isSelected){
        return;
    }
    
    
    BankInfo *item = [[DataRegister instance] getBankItem];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    
    NSNumber *averageSales = [f numberFromString:self.txtAverageSalePerCustomer.text];
    NSNumber *monthlySales = [f numberFromString:self.txtMonthlySales.text];
    NSNumber *saleTypeID = [NSNumber numberWithInt:0];
    if ([self.btnNonPerson isSelected]) {
        saleTypeID = [NSNumber numberWithInt:1];
    }
    
    item.SaleTypeID = saleTypeID;
    item.AverageSale = averageSales;
    item.MonthlySales = monthlySales;
    item.BankName = self.txtBankName.text;
    item.RountingNumber = self.txtBankRoutingName.text;
    item.AccountNumber = self.txtBankAccountingNumber.text;
    
    [self submitForm];
}

- (IBAction)onTermsCondition:(id)sender {
    TermsAndConditionsViewController * controller = [[TermsAndConditionsViewController alloc]initWithNibName:@"TermsAndConditionsViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onSelectPersonInfo:(id)sender {
    if(sender == self.btnInPerson){
        [self.btnInPerson setSelected:YES];
        [self.btnNonPerson setSelected:NO];
    }else if(sender == self.btnNonPerson){
        [self.btnInPerson setSelected:NO];
        [self.btnNonPerson setSelected:YES];
    }
}

#pragma mark - Form Submission
/*
request code:

{
    "rqd": {
        "stid": 1,
        "avs": 1,
        "ms": 1,
        "bn": "Bank of Chase",
        "rtn": "1234",
        "act": "1111"
    },
    "sd": {
        "mid": 123,
        "uem": "user@abc.net",
        "uid": 987,
        "ldk": "Mobile123"
    }
 }
 */

- (void) progressTask {
    
    NewSignatureViewController *viewctrl = [[NewSignatureViewController alloc] initWithMerchantKey:merchantKey andFullName:@""];
    viewctrl.delegate = self;
    
    PSAAppDelegate * appDelegate = (PSAAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController presentViewController:viewctrl animated:YES completion:nil];
    return;
    
    BankInfo *item = [[DataRegister instance] getBankItem];
    NSDictionary * dict = @{
                            @"stid": item.SaleTypeID,
                            @"avs": item.AverageSale,
                            @"ms": item.MonthlySales,
                            @"bn": item.BankName,
                            @"rtn": item.RountingNumber,
                            @"act": item.AccountNumber,
                            };
    
    self.dal = [[ServiceDAL alloc] initWiThPostData:dict urlString:URL_MERCHANT_ACCOUNTINFO delegate:self];
    [self.dal startAsync];
}

- (void) handleServiceResponseWithDict:(NSDictionary *)dictionary {
    if ([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_ACCOUNTINFO]) {
        /// new account success
    }
    
    
    
    NewSignatureViewController *viewctrl = [[NewSignatureViewController alloc] initWithMerchantKey:merchantKey andFullName:@""];
    viewctrl.delegate = self;
    
    PSAAppDelegate * appDelegate = (PSAAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController presentViewController:viewctrl animated:YES completion:nil];
    return;

}

- (void)signatureCompleted {
    NewConfirmationViewController *vc = [[NewConfirmationViewController alloc] initWithNibName:@"NewConfirmationViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];

}
@end
