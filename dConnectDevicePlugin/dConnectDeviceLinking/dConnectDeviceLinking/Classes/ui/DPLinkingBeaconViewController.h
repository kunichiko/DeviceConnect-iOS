//
//  DPLinkingBeaconViewController.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPLinkingBeaconManager.h"

@interface DPLinkingBeaconViewController : UITableViewController

@property (nonatomic) DPLinkingBeaconManager *beaconManager;
@property (nonatomic) DPLinkingBeacon *beacon;

@end
