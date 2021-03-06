//
//  DPHitoeStressEstimationData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPHitoeStressEstimationData : NSObject<NSCopying>
@property (nonatomic,assign) double lfhf;
@property (nonatomic, assign) long long timeStamp;
@property (nonatomic, strong) NSString *timeStampString;
- (DConnectMessage*)toDConnectMessage;

@end
