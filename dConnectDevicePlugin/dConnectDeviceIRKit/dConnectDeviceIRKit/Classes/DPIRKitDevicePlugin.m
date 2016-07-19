//
//  DPIRKitDevicePlugin.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitDevicePlugin.h"
#import "DPIRKit_irkit.h"
#import "DPIRKitRemoteControllerProfile.h"
#import "DPIRKitConst.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitRESTfulRequest.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitServiceInformationProfile.h"
#import "DPIRKitLightProfile.h"
#import "DPIRKitTVProfile.h"
#import "DPIRKitService.h"

NSString *const DPIRKitInfoVersion = @"DPIRKitVersion";
NSString *const DPIRKitInfoAPIKey = @"DPIRKitAPIKey";
NSString *const DPIRKitStoryBoardName = @"Storyboard_";
NSString *const DPIRKitPluginName = @"IRKit (Device Connect Device Plug-in)";

// Const.h
NSString *const DPIRKitBundleName = @"dConnectDeviceIRKit_resources";
NSString *const DPIRKitInfoPlistName = @"dConnectDeviceIRKit-Info";

@interface DPIRKitDevicePlugin()
<
// プロファイルデリゲート
DConnectServiceInformationProfileDataSource,
DConnectSystemProfileDataSource,

// デバイス検知デリゲート
DPIRKitManagerDetectionDelegate
>

{
    NSMutableDictionary *_devices;
    DConnectEventManager *_eventManager;
    NSString *_version;
    
    /*!
     @brief Service生成時に登録するプロファイル(DConnectProfile *)の配列
     */
    NSArray *mServiceProfiles;
}

- (void) sendDeviceDetectionEventWithDevice:(DPIRKitDevice *)device online:(BOOL)online;

- (void) startObeservation;
- (void) stopObeservation;

@end

@implementation DPIRKitDevicePlugin

#pragma mark - Initializaion

- (id) init {
    
    self = [super initWithObject: self];
    
    if (self) {
        DConnectSystemProfile *systemProfile = [DConnectSystemProfile new];
        systemProfile.dataSource = self;
        [self addProfile:systemProfile];
        
        // サービスで登録するProfile
        DPIRKitServiceInformationProfile *serviceInformationProfile = [DPIRKitServiceInformationProfile new];
        DPIRKitRemoteControllerProfile *remoteControllerProfile
                            = [[DPIRKitRemoteControllerProfile alloc] initWithDevicePlugin:self];
        DPIRKitTVProfile *tvProfile = [[DPIRKitTVProfile alloc] initWithDevicePlugin:self];
        DPIRKitLightProfile *lightProfile = [[DPIRKitLightProfile alloc] initWithDevicePlugin:self];
        serviceInformationProfile.dataSource = self;
        mServiceProfiles = @[ serviceInformationProfile, remoteControllerProfile, tvProfile, lightProfile ];
        
        _devices = [NSMutableDictionary dictionary];
        id<DConnectEventCacheController> controller = [[DConnectMemoryCacheController alloc] init];
        _eventManager = [DConnectEventManager sharedManagerForClass:[DPIRKitDevicePlugin class]];
        [_eventManager setController:controller];
        NSString* path = [DPIRBundle() pathForResource:DPIRKitInfoPlistName ofType:@"plist"];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
        _version = info[DPIRKitInfoVersion];
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            [notificationCenter addObserver:_self selector:@selector(startObeservation)
                       name:UIApplicationWillEnterForegroundNotification
                     object:application];
            [notificationCenter addObserver:_self selector:@selector(stopObeservation)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:application];
            DPIRKitManager *manager = [DPIRKitManager sharedInstance];
            manager.apiKey = info[DPIRKitInfoAPIKey];
            manager.detectionDelegate = _self;
            
            [_self startObeservation];
        });
        self.pluginName = DPIRKitPluginName;
    }
    
    return self;
}

- (void) dealloc {
    _devices = nil;
    _eventManager = nil;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];

    [self stopObeservation];
}

#pragma mark - Public Methods

- (DPIRKitDevice *) deviceForServiceId:(NSString *)serviceId {
    @synchronized (_devices) {
        return [_devices objectForKey:serviceId];
    }
}

#pragma mark - Private Methods

- (void) sendDeviceDetectionEventWithDevice:(DPIRKitDevice *)device online:(BOOL)online {
    [[DPIRKitManager sharedInstance] startDetection];
    BOOL hit = NO;
    @synchronized (_devices) {
        
        DPIRKitDevice *irkit = _devices[device.name];
        
        if (irkit) {
            hit = YES;
            if (!online) {
                [_devices removeObjectForKey:device.name];
            }
        } else if (online) {
            _devices[device.name] = device;
        }
    }
    if ((!hit && online) || (hit && !online)) {
        
        // デバイスが未登録なら登録する
        NSString *serviceId = device.name;
        if (![self.mServiceProvider service: serviceId]) {
            DPIRKitService *service = [[DPIRKitService alloc] initWithServiceId: serviceId profiles: mServiceProfiles];
            [self.mServiceProvider addService: service];
        }
        
        NSArray *events = [_eventManager eventListForProfile:DConnectServiceDiscoveryProfileName
                                                   attribute:DConnectServiceDiscoveryProfileAttrOnServiceChange];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *message = [DConnectMessage message];
            [message setString:@"" forKey:DConnectMessageServiceId];
            [message setString:DConnectServiceDiscoveryProfileName forKey:DConnectMessageProfile];
            [message setString:DConnectServiceDiscoveryProfileAttrOnServiceChange forKey:DConnectMessageAttribute];
            [message setString:event.sessionKey forKey:DConnectMessageSessionKey];
            [self sendEvent:message];
        }
    } else {
        // デバイスが登録済なら登録解除する
        NSString *serviceId = device.name;
        DConnectService *service = [self.mServiceProvider service: serviceId];
        if (service) {
            [self.mServiceProvider removeService: service];
        }
        
    }
}

- (void) startObeservation {
    
    @synchronized (_devices) {
        [_devices removeAllObjects];
    }
    
    [[DPIRKitManager sharedInstance] startDetection];
}

- (void) stopObeservation {
    [[DPIRKitManager sharedInstance] stopDetection];
}

// 一つでも赤外線が登録されているかをチェックする
- (BOOL) existIRForServiceId:(NSString *)serviceId {
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                  profile:nil];
    for (DPIRKitRESTfulRequest *request in requests) {
        DPIRLog(@"%@:%@", request.name,request.ir);
        NSRange range = [request.ir rangeOfString:@"{\"format\":\"raw\","];
        if (request.ir && range.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Profile Delegate

#pragma mark DConnectSystemProfileDataSource

- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile {
    return _version;
}

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    
    NSBundle *bundle = DPIRBundle();
    
    // iphoneとipadでストーリーボードを切り替える
    UIStoryboard *storyBoard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPhone", DPIRKitStoryBoardName]
                                       bundle:bundle];
    } else{
        storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@iPad", DPIRKitStoryBoardName]
                                       bundle:bundle];
    }
    UINavigationController *viewController = [storyBoard instantiateInitialViewController];
    return viewController;
}

#pragma mark DConnectSystemProfileDataSource

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                        wifiStateForServiceId:(NSString *)serviceId
{
    
    DConnectServiceInformationProfileConnectState state = DConnectServiceInformationProfileConnectStateOff;
    // TODO: 実際に接続を確認した方が良いかの検討
    @synchronized (_devices) {
        if (_devices.count > 0) {
            DPIRKitDevice *device = [_devices objectForKey:serviceId];
            if (device) {
                state = DConnectServiceInformationProfileConnectStateOn;
            }
        }
    }
    
    return state;
}

#pragma mark - DPIRKitManagerDetectionDelegate

- (void) manager:(DPIRKitManager *)manager didFindDevice:(DPIRKitDevice *)device {
    
    NSLog(@"found a device : %@", device);
    [self sendDeviceDetectionEventWithDevice:device online:YES];
}

- (void) manager:(DPIRKitManager *)manager didLoseDevice:(DPIRKitDevice *)device {
    NSLog(@"lost a device : %@", device);
    [self sendDeviceDetectionEventWithDevice:device online:NO];
}


- (BOOL)sendIRWithServiceId:(NSString *)serviceId
                    message:(NSString *)message
                   response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *ids = [serviceId componentsSeparatedByString:@"."];
    DPIRKitDevice *device = [[DPIRKitManager sharedInstance] deviceForServiceId:ids[0]];
    if (message) {
        NSData *jsonData = [message dataUsingEncoding:NSUnicodeStringEncoding];
        id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:NULL];
        if (![NSJSONSerialization isValidJSONObject:jsonObj]) {
            [response setErrorToInvalidRequestParameter];
            return send;
        }
    }
    if (!message) {
        [response setErrorToInvalidRequestParameter];
    } else {
        send = NO;
        [[DPIRKitManager sharedInstance] sendMessage:message withHostName:device.hostName completion:^(BOOL success) {
            if (success) {
                response.result = DConnectMessageResultTypeOk;
            } else {
                [response setErrorToUnknown];
            }
            
            [[DConnectManager sharedManager] sendResponse:response];
        }];
    }
    return send;
}


@end
