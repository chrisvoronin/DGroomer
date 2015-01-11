#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CompanyViewController: UIViewController {
	
	IBOutlet UITextField	*ownerName;
	IBOutlet UITextField	*companyName;
	IBOutlet UITextField	*address1;
	IBOutlet UITextField	*address2;
	IBOutlet UITextField	*city;
	IBOutlet UITextField	*state;
	IBOutlet UITextField	*zipCode;
	IBOutlet UITextField	*phone;
	IBOutlet UITextField	*fax;
	
}

@property (nonatomic, retain) IBOutlet UITextField *ownerName;
@property (nonatomic, retain) IBOutlet UITextField *companyName;
@property (nonatomic, retain) IBOutlet UITextField *address1;
@property (nonatomic, retain) IBOutlet UITextField *address2;
@property (nonatomic, retain) IBOutlet UITextField *city;
@property (nonatomic, retain) IBOutlet UITextField *state;
@property (nonatomic, retain) IBOutlet UITextField *zipCode;
@property (nonatomic, retain) IBOutlet UITextField *fax;

- (IBAction)cancelEditClient:(id)sender;
- (IBAction)doEditClient:(id)sender;


@end
