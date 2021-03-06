//
//  TestVibrationProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestVibrationProfile.h"

@implementation TestVibrationProfile

- (id) init {
    self = [super init];
    
    if (self) {

        // API登録(didReceivePutVibrateRequest相当)
        NSString *putVibrateRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectVibrationProfileAttrVibrate];
        [self addPutPath: putVibrateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteVibrateRequest相当)
        NSString *deleteVibrateRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectVibrationProfileAttrVibrate];
        [self addDeletePath: deleteVibrateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

@end
