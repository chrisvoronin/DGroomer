//
//  PSAReminderViewController.m
//  iBiz
//
//  Created by johnny on 2/14/15.
//  Copyright (c) 2015 SalonTechnologies, Inc. All rights reserved.
//

#import "PSAReminderViewController.h"
#import "ConfigurationUtility.h"
#import "DataRegister.h"
#import "PSADataManager.h"
#import "Company.h"

@interface PSAReminderViewController ()

@end

@implementation PSAReminderViewController
@synthesize strEmailContent, strEmailTo, strEmailSubject, strTextTo, isEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self submitForm];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated {
    //[self submitForm];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) progressTask
{
    [progress show:YES];
    if(isEmail!=1){
        Company *company = [[PSADataManager sharedInstance] getCompany];
        NSDictionary * dict = nil;
        dict = @{
             @"ef" : [NSString stringWithFormat:@"%@", company.companyEmail]
             , @"et" : [NSString stringWithFormat:@"%@", strEmailTo]
             , @"es" : [NSString stringWithFormat:@"%@", strEmailSubject]
             , @"ec" : [NSString stringWithFormat:@"%@", strEmailContent]
             };
        self.dal = [[ServiceDAL alloc] initWiThPostData:dict urlString:URL_MERCHANT_SENDREMINDER delegate:self];
        [self.dal startAsync];
    } else{
        strTextTo = [strTextTo stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *strDict = [[NSString stringWithFormat:@"?phone=%@&text=%@. %@&token=raj12345", strTextTo, strEmailSubject, strEmailContent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        strDict = [strDict stringByReplacingOccurrencesOfString:@"\n" withString:@"%20"];
        self.dal = [[ServiceDAL alloc] initWiThHttpGetData:strDict urlString:URL_MERCHANT_SENDMESSAGE delegate:self];
        [self.dal startAsync];
    }

}

- (void) handleServiceResponseErrorMessage:(NSString *)error
{
    [self.progress hide:YES];
    
    if (error != nil && ![error isEqualToString:@""])
    {
        if( self.navigationController.viewControllers.count == 1 ) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
        //[[[UIAlertView alloc] initWithTitle:@"Unexpected Server Error!" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void) handleServiceResponseWithDict:(NSDictionary *)dictionary
{
    if ([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_SENDREMINDER] && isEmail==2) {
        isEmail = -1;
        strTextTo = [strTextTo stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *strDict = [[NSString stringWithFormat:@"?phone=%@&text=%@. %@&token=raj12345", strTextTo, strEmailSubject, strEmailContent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        strDict = [strDict stringByReplacingOccurrencesOfString:@"\n" withString:@"%20"];
        self.dal = [[ServiceDAL alloc] initWiThHttpGetData:strDict urlString:URL_MERCHANT_SENDMESSAGE delegate:self];
        [self.dal startAsync];
        return;
    }
    if ([ErrorXmlParser checkResponseError:dictionary :URL_MERCHANT_SENDMESSAGE]) {
        [self.progress hide:YES];
        if( self.navigationController.viewControllers.count == 1 ) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
    /*if( self.navigationController.viewControllers.count == 1 ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }*/


}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
