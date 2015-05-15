//
//  TestMediaStreamRecordingProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestMediaStreamRecordingProfile.h"
#import "DeviceTestPlugin.h"


NSString *const TestMediaStreamID = @"test_camera_id";
NSString *const TestMediaStreamName = @"test_camera_name";
const int TestMediaStreamImageWidth = 1920;
const int TestMediaStreamImageHeight = 1080;
NSString *const TestMediaStreamMimeType = @"video/mp4";
NSString *const TestMediaStreamConfig = @"test_config";
NSString *const TestMediaStreamUri = @"content://test/test.mp4";
NSString *const TestMediaStreamPhotoPath = @"test.png";
NSString *const TestMediaStreamVideoPath = @"test.mp4";


@implementation TestMediaStreamRecordingProfile

- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _plugin = plugin;
    }
    
    return self;
}

#pragma mark - Get Methods

- (BOOL)                      profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveGetMediaRecorderRequest:(DConnectRequestMessage *)request
                             response:(DConnectResponseMessage *)response
                            serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        DConnectArray *recorders = [DConnectArray array];
        
        DConnectMessage *recorder = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setRecorderId:TestMediaStreamID target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderName:TestMediaStreamName target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
                                                       target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderImageWidth:TestMediaStreamImageWidth target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderImageHeight:TestMediaStreamImageHeight target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderMIMEType:TestMediaStreamMimeType target:recorder];
        [DConnectMediaStreamRecordingProfile setRecorderConfig:TestMediaStreamConfig target:recorder];
        
        [recorders addMessage:recorder];
        [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
    }
    
    return YES;
}

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveGetOptionsRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        DConnectMessage *imageWidth = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setMin:0 target:imageWidth];
        [DConnectMediaStreamRecordingProfile setMax:0 target:imageWidth];
        [DConnectMediaStreamRecordingProfile setImageWidth:imageWidth target:response];
        
        DConnectMessage *imageHeight = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setMin:0 target:imageHeight];
        [DConnectMediaStreamRecordingProfile setMax:0 target:imageHeight];
        [DConnectMediaStreamRecordingProfile setImageHeight:imageHeight target:response];
        
        DConnectArray *mimeTypes = [DConnectArray array];
        [mimeTypes addString:TestMediaStreamMimeType];
        [DConnectMediaStreamRecordingProfile setMIMETypes:mimeTypes target:response];
    }
    
    return YES;
}

#pragma mark - Post Methods

- (BOOL)                   profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceivePostTakePhotoRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                         serviceId:(NSString *)serviceId
                            target:(NSString *)target
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:response];
        [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamPhotoPath target:response];
    }
    
    return YES;
}

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceivePostRecordRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
                      timeslice:(NSNumber *)timeslice
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:response];
        [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamVideoPath target:response];
    }
    
    return YES;
}


#pragma mark - Put Methods

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
      didReceivePutPauseRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
{
    
    CheckDID(response, serviceId)
    if (target != nil && target.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}


- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
     didReceivePutResumeRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *) target
{
    CheckDID(response, serviceId)
    if (target != nil && target.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
       didReceivePutStopRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
{
    CheckDID(response, serviceId)
    if (target != nil && target.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}


- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
  didReceivePutMuteTrackRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
{
    CheckDID(response, serviceId)
    if (target != nil && target.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePutUnmuteTrackRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
{
    CheckDID(response, serviceId)
    if (target != nil && target.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}

- (BOOL)                profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceivePutOptionsRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                         target:(NSString *)target
                     imageWidth:(NSNumber *)imageWidth
                    imageHeight:(NSNumber *)imageHeight
                       mimeType:(NSString *)mimeType
{
    
    CheckDID(response, serviceId)
    if (target == nil || target.length == 0
        || imageWidth == nil || imageHeight == nil
        || mimeType == nil || mimeType.length == 0)
    {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

#pragma mark Event Registration

- (BOOL)               profile:(DConnectMediaStreamRecordingProfile *)profile
   didReceivePutOnPhotoRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                    sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectMediaStreamRecordingProfileAttrOnPhoto forKey:DConnectMessageAttribute];

        DConnectMessage *photo = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamPhotoPath target:photo];
        [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:photo];
        [DConnectMediaStreamRecordingProfile setPhoto:photo target:event];
        [_plugin asyncSendEvent:event];
    }
    
    return YES;
}

- (BOOL)                        profile:(DConnectMediaStreamRecordingProfile *)profile
  didReceivePutOnRecordingChangeRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectMediaStreamRecordingProfileAttrOnRecordingChange
                  forKey:DConnectMessageAttribute];
        
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setStatus:DConnectMediaStreamRecordingProfileRecordingStateRecording
                                                target:media];
        [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:media];
        [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamVideoPath target:media];
        [DConnectMediaStreamRecordingProfile setMedia:media target:event];
        [_plugin asyncSendEvent:event];
    }

    
    return YES;
}

- (BOOL)                        profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceivePutOnDataAvailableRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectMediaStreamRecordingProfileAttrOnDataAvailable
                  forKey:DConnectMessageAttribute];
        
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:media];
        [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:media];
        [DConnectMediaStreamRecordingProfile setMedia:media target:event];
        [_plugin asyncSendEvent:event];
    }

    
    return YES;
}

#pragma mark - Delete Methods
#pragma mark Event Unregstration

- (BOOL)                   profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveDeleteOnPhotoRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                         serviceId:(NSString *)serviceId
                        sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}

- (BOOL)                             profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveDeleteOnRecordingChangeRequest:(DConnectRequestMessage *)request
                                    response:(DConnectResponseMessage *)response
                                   serviceId:(NSString *)serviceId
                                  sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

- (BOOL)                           profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveDeleteOnDataAvailableRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                 serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}


@end