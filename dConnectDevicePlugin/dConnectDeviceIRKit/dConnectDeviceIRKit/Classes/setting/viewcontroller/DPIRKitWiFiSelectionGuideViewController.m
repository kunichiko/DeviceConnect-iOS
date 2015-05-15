//
//  DPIRKitWiFiSelectionGuideViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKit_irkit.h"
#import "DPIRKitWiFiSelectionGuideViewController.h"
#import "DPIRKitConst.h"
#import "DPIRKitReachability.h"

typedef NS_ENUM(NSUInteger, DPIRKitSelectionState) {
    DPIRKitSelectionStateIdling = 0,
    DPIRKitSelectionStateGotDeviceKey,
    DPIRKitSelectionStateWaitingIRKitSSID,
    DPIRKitSelectionStateCheckingIRKit,
};

@interface DPIRKitWiFiSelectionGuideViewController ()<UIAlertViewDelegate>
{
    DPIRKitSelectionState _state;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;
@property (weak, nonatomic) IBOutlet UIView *indBackView;

- (void) showAlertWithTileKey:(NSString *)titleKey
                  messsageKey:(NSString *)messageKey
               closeButtonKey:(NSString *)closeButtonKey
                     delegate:(id<UIAlertViewDelegate>)delegate;

- (void) createNewDeviceWithClientKey:(NSString *)clientKey;
- (void) showNoNetworkError;
- (void) startLoading;
- (void) stopLoading;

- (void) enterForground;

@end

@implementation DPIRKitWiFiSelectionGuideViewController

- (void) showAlertWithTileKey:(NSString *)titleKey
                  messsageKey:(NSString *)messageKey
               closeButtonKey:(NSString *)closeButtonKey
                     delegate:(id<UIAlertViewDelegate>)delegate
{
    
    __weak typeof(self) _self = self;
    NSBundle *bundle = DPIRBundle();
    
    UIAlertView *alert
    = [[UIAlertView alloc] initWithTitle:DPIRLocalizedString(bundle, titleKey)
                                 message:DPIRLocalizedString(bundle, messageKey)
                                delegate:delegate
                       cancelButtonTitle:nil
                       otherButtonTitles:DPIRLocalizedString(bundle, closeButtonKey), nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_self stopLoading];
        [alert show];
    });
    
}

- (void) showNoNetworkError {
    
    [self showAlertWithTileKey:@"AlertTitleError"
                   messsageKey:@"AlertMessageNoNetworkError"
                closeButtonKey:@"AlertBtnClose"
                      delegate:self];
}

- (void) startLoading {
    _indBackView.hidden = NO;
    _indView.hidden = NO;
    [_indView startAnimating];
    [self setScrollEnable:NO];
}

- (void) stopLoading {
    _indBackView.hidden = YES;
    _indView.hidden = YES;
    [_indView stopAnimating];
    [self setScrollEnable:YES];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _state = DPIRKitSelectionStateIdling;
    _indView.hidden = YES;
    _indBackView.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter addObserver:self selector:@selector(enterForground)
               name:UIApplicationWillEnterForegroundNotification
             object:application];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *clientKey = [userDefaults stringForKey:DPIRKitUDKeyClientKey];
    
    if (!clientKey) {
        
        DPIRKitReachability *reachability = [DPIRKitReachability reachabilityForInternetConnection];
        DPIRKitNetworkStatus status = [reachability currentReachabilityStatus];
        
        if (status == DPIRKitNotReachable) {
            [self showNoNetworkError];
        } else {
            
            [self startLoading];
            __weak typeof(self) _self = self;
            
            [[DPIRKitManager sharedInstance]
                fetchClientKeyWithCompletion:^(NSString *clientKey,
                                               DPIRKitConnectionErrorCode errorCode) {
                
                if (clientKey) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:clientKey forKey:DPIRKitUDKeyClientKey];
                    [userDefaults synchronize];
                    [_self createNewDeviceWithClientKey:clientKey];
                } else {
                    [_self showNoNetworkError];
                }
            }];
        }
    } else {
        NSString *deviceKey = [userDefaults stringForKey:DPIRKitUDKeyDeviceKey];
        if (!deviceKey) {
            [self startLoading];
            [self createNewDeviceWithClientKey:clientKey];
        }
    }
}

- (void) createNewDeviceWithClientKey:(NSString *)clientKey {
    
    __weak typeof(self) _self = self;
    
    [[DPIRKitManager sharedInstance] createNewDeviceWithClientKey:clientKey
                                                       completion:^(NSString *serviceId,
                                                                    NSString *deviceKey,
                                                                    DPIRKitConnectionErrorCode errorCode)
     {
         if (deviceKey && serviceId) {
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults setValue:deviceKey forKey:DPIRKitUDKeyDeviceKey];
             [userDefaults setValue:serviceId forKey:DPIRKitUDKeyServiceId];
             [userDefaults synchronize];
             
             @synchronized (_self) {
                 _state = DPIRKitSelectionStateGotDeviceKey;
             }
             
             [_self showAlertWithTileKey:@"AlertTitlePrepared"
                             messsageKey:@"AlertMessagePrepared"
                          closeButtonKey:@"AlertBtnClose"
                                delegate:_self];
             
         } else {
             [_self showNoNetworkError];
         }
     }];
}

- (void) viewDidDisappear:(BOOL)animated {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    [notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:application];
}

- (void) enterForground {
    
    @synchronized (self) {
        if (_state == DPIRKitSelectionStateWaitingIRKitSSID) {
            __weak typeof(self) _self = self;
            _state = DPIRKitSelectionStateCheckingIRKit;
            [self startLoading];
            [[DPIRKitManager sharedInstance] checkIfCurrentSSIDIsIRKitWithCompletion:
             ^(BOOL isIRKit, NSError *error)
             {
                 if (isIRKit) {
                     
                     @synchronized (_self) {
                         _state = DPIRKitSelectionStateIdling;
                     }
                     [_self showAlertWithTileKey:@"AlertTitlePrepared"
                                     messsageKey:@"AlertMessageIsIRKit"
                                  closeButtonKey:@"AlertBtnClose"
                                        delegate:nil];
                     
                 } else {
                     [_self showAlertWithTileKey:@"AlertTitleError"
                                     messsageKey:@"AlertMessageIsNotIRKit"
                                  closeButtonKey:@"AlertBtnClose"
                                        delegate:_self];
                 }
             }];
            
        }
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    @synchronized (self) {
        if (_state == DPIRKitSelectionStateGotDeviceKey) {
            _state = DPIRKitSelectionStateWaitingIRKitSSID;
            [self setScrollEnable:NO closeBtn:YES];
        } else if (_state == DPIRKitSelectionStateCheckingIRKit) {
            _state = DPIRKitSelectionStateWaitingIRKitSSID;
            [self setScrollEnable:NO closeBtn:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end