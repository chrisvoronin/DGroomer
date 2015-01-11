#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TimeClockController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *myTableView;
	IBOutlet UITextField *myStartTime;
	IBOutlet UITextField *myEndTime;
	
	NSDate	*startTime;
	NSDate	*endTime;
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;

- (IBAction)addCancel:(id)sender;
- (IBAction)addDone:(id)sender;


@end
