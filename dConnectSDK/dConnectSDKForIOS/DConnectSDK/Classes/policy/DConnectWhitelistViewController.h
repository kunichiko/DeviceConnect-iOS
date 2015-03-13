//
//  DConnectWhitelistViewController
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface DConnectWhitelistViewController : UITableViewController

@property IBOutlet UIBarButtonItem *addButton;

- (IBAction) closeAction:(id) sender;
- (IBAction) didEnteredNewOriginForSegue:(UIStoryboardSegue *)segue;

@end

@interface DConnectOriginBlockingCell : UITableViewCell

@property IBOutlet UISwitch *blockingSwitch;

@end