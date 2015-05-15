//
//  DPHostVibrationProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AudioToolbox/AudioToolbox.h>

#import "DPHostVibrationProfile.h"
#import "DPHostUtils.h"

@implementation DPHostVibrationProfile

- (instancetype)init
{
    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        // iPhoneを除く以下のモデルは振動機能無しという事にする。
        // iPod touch, iPhone Simulator, iPad, iPad Simulator
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - Put Methods

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!self.delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DConnectVibrationProfileAttrVibrate]) {
        NSString *patternStr = [DConnectVibrationProfile patternFromRequest:request];
        NSArray *pattern = patternStr ? [self parsePattern:patternStr] : nil;
        send = [self profile:self didReceivePutVibrateRequest:request response:response
                    serviceId:[request serviceId] pattern:pattern];
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}
- (BOOL)existNumberInArray:(NSArray*)pattern
{
    if (pattern) {
        for (NSNumber *pat in pattern) {
            if (![DPHostUtils existDigitWithString:pat.stringValue]
                || pat.intValue < 0) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - DConnectVibrationProfileDelegate

// バイブ鳴動開始リクエストを受け取った
- (BOOL)            profile:(DConnectVibrationProfile *)profile
didReceivePutVibrateRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    pattern:(NSArray *) pattern
{
    NSString *patternString = [request stringForKey:DConnectVibrationProfileParamPattern];
    if ((patternString
         && ![DPHostUtils existCSVWithString:patternString]
         && ![DPHostUtils existDigitWithString:patternString])
        || (patternString
            && [DPHostUtils existCSVWithString:patternString]
            && ![self existNumberInArray:pattern])
        || (patternString
            && [DPHostUtils existCSVWithString:patternString]
            && ![DPHostUtils existDigitWithString:patternString]
            && ![self existNumberInArray:pattern])
        ) {
        [response setErrorToInvalidRequestParameter];
        return YES;
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [response setResult:DConnectMessageResultTypeOk];

    return YES;
}

#pragma mark - Delete Methods
- (BOOL)               profile:(DConnectVibrationProfile *)profile
didReceiveDeleteVibrateRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    [response setErrorToNotSupportProfileWithMessage:@"Vibration Stop API is not supported."];
    return YES;
}

@end