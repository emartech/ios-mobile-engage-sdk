//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import "EMSRequestModelBuilder.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestModel.h"
#import "MobileEngageStatusDelegate.h"
#import "MEConfig.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "NSData+MobileEngine.h"
#import "MEDefaultHeaders.h"
#import "MobileEngageVersion.h"
#import "EMSResponseModel.h"
#import "AbstractResponseHandler.h"
#import "MEIdResponseHandler.h"
#import "EMSTimestampProvider.h"
#import "MEIAMViewController.h"
#import "MEJSBridge.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAM.h"
#import "MEIAM+Private.h"
#import "MEIAMResponseHandler.h"
#import "MEExperimental.h"

@interface MobileEngageInternal ()

@property(nonatomic, strong) MEConfig *config;
@property(nonatomic, strong) NSArray<AbstractResponseHandler *> *responseHandlers;

- (NSString *)trackCustomEventV2:(nonnull NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes;

@end

@implementation MobileEngageInternal

- (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions {

    [MEExperimental enableFeatures:config.experimentalFeatures];
    _lastAppLoginPayload = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] dictionaryForKey:kLastAppLoginPayload];
    _meId = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] stringForKey:kMEID];
    _requestManager = requestManager;
    _config = config;
    [requestManager setAdditionalHeaders:[MEDefaultHeaders additionalHeadersWithConfig:self.config]];
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        _responseHandlers = @[[[MEIdResponseHandler alloc] initWithMobileEngageInternal:self], [MEIAMResponseHandler new]];
    } else {
        _responseHandlers = @[];
    }
    _timestampProvider = [EMSTimestampProvider new];
}

- (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    __weak typeof(self) weakSelf = self;
    _successBlock = ^(NSString *requestId, EMSResponseModel *responseModel) {
        [weakSelf handleResponse:responseModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageLogReceivedWithEventId:log:)]) {
                [weakSelf.statusDelegate mobileEngageLogReceivedWithEventId:requestId
                                                                        log:@"Success"];
            }
        });
    };
    _errorBlock = ^(NSString *requestId, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.statusDelegate respondsToSelector:@selector(mobileEngageErrorHappenedWithEventId:error:)]) {
                [weakSelf.statusDelegate mobileEngageErrorHappenedWithEventId:requestId
                                                                        error:error];
            }
        });
    };
    [self setupWithRequestManager:[EMSRequestManager managerWithSuccessBlock:self.successBlock
                                                                  errorBlock:self.errorBlock]
                           config:config
                    launchOptions:launchOptions];
}

- (void)handleResponse:(EMSResponseModel *)model {
    for (AbstractResponseHandler *handler in _responseHandlers) {
        [handler processResponse:model];
    }
}

- (void)setPushToken:(NSData *)pushToken {
    _pushToken = pushToken;

    if (self.lastAppLoginParameters != nil) {
        [self appLoginWithContactFieldId:self.lastAppLoginParameters.contactFieldId contactFieldValue:self.lastAppLoginParameters.contactFieldValue];
    }
}

- (NSString *)appLogin {
    return [self appLoginWithContactFieldId:nil contactFieldValue:nil];
}

- (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue {
    self.lastAppLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:contactFieldId
                                                                   contactFieldValue:contactFieldValue];

    EMSRequestModel *requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"
                                                       method:HTTPMethodPOST
                                       additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                           payload[@"platform"] = @"ios";
                                           payload[@"language"] = [EMSDeviceInfo languageCode];
                                           payload[@"timezone"] = [EMSDeviceInfo timeZone];
                                           payload[@"device_model"] = [EMSDeviceInfo deviceModel];
                                           payload[@"os_version"] = [EMSDeviceInfo osVersion];
                                           payload[@"ems_sdk"] = MOBILEENGAGE_SDK_VERSION;

                                           NSString *appVersion = [EMSDeviceInfo applicationVersion];
                                           if (appVersion) {
                                               payload[@"application_version"] = appVersion;
                                           }
                                           if (self.pushToken) {
                                               payload[@"push_token"] = [self.pushToken deviceTokenString];
                                           } else {
                                               payload[@"push_token"] = @NO;
                                           }
                                       }];

    if ([self.lastAppLoginPayload isEqual:requestModel.payload]) {
        requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"
                                          method:HTTPMethodPOST
                          additionalPayloadBlock:nil];
    } else {
        self.lastAppLoginPayload = requestModel.payload;
    }

    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (EMSRequestModel *)requestModelWithUrl:(NSString *)url
                                  method:(HTTPMethod)method
                  additionalPayloadBlock:(void (^)(NSMutableDictionary *payload))payloadBlock {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:url];
        [builder setMethod:method];
        NSMutableDictionary *payload = [@{
                @"application_id": self.config.applicationCode,
                @"hardware_id": [EMSDeviceInfo hardwareId]
        } mutableCopy];

        if (self.lastAppLoginParameters.contactFieldId && self.lastAppLoginParameters.contactFieldValue) {
            payload[@"contact_field_id"] = self.lastAppLoginParameters.contactFieldId;
            payload[@"contact_field_value"] = self.lastAppLoginParameters.contactFieldValue;
        }

        if (payloadBlock) {
            payloadBlock(payload);
        }

        [builder setPayload:payload];
    }];
    return requestModel;
}

- (NSString *)appLogout {
    EMSRequestModel *requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout" method:HTTPMethodPOST additionalPayloadBlock:nil];

    [self.requestManager submit:requestModel];
    self.lastAppLoginParameters = nil;
    self.lastAppLoginPayload = nil;
    self.meId = nil;
    return requestModel.requestId;
}

- (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSString *requestId;
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open" method:HTTPMethodPOST additionalPayloadBlock:^(NSMutableDictionary *payload) {
            payload[@"sid"] = messageId;
        }];
        [self.requestManager submit:requestModel];
        requestId = [requestModel requestId];
    } else {
        requestId = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
        }].requestId;
        self.errorBlock(requestId, [NSError errorWithCode:1
                                     localizedDescription:@"Missing messageId"]);
    }
    return requestId;
}

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage {
    NSParameterAssert(inboxMessage);
    EMSRequestModel *requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                       method:HTTPMethodPOST
                                       additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                           payload[@"sid"] = inboxMessage.sid;
                                           payload[@"source"] = @"inbox";
                                       }];
    [self.requestManager submit:requestModel];
    return [requestModel requestId];
}

- (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    if (![MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        return [self trackCustomEventV2:eventName
                        eventAttributes:eventAttributes];
    }

    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setMethod:HTTPMethodPOST];
        [builder setUrl:[NSString stringWithFormat:@"https://ems-me-deviceevent.herokuapp.com/v3/devices/%@/events", _meId]];
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"clicks"] = @[];
        payload[@"viewed_messages"] = @[];
        payload[@"hardware_id"] = [EMSDeviceInfo hardwareId];

        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                @"type": @"custom",
                @"name": eventName,
                @"timestamp": [_timestampProvider currentTimeStamp]}];

        if (eventAttributes) {
            event[@"attributes"] = eventAttributes;
        }

        payload[@"events"] = @[event];

        [builder setPayload:payload];
    }];

    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (NSString *)trackCustomEventV2:(nonnull NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [self requestModelWithUrl:[NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName]
                                                       method:HTTPMethodPOST
                                       additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                           payload[@"attributes"] = eventAttributes;
                                       }];
    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (void)setLastAppLoginPayload:(NSDictionary *)lastAppLoginPayload {
    _lastAppLoginPayload = lastAppLoginPayload;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:lastAppLoginPayload
                     forKey:kLastAppLoginPayload];
    [userDefaults synchronize];
}

- (void)setMeId:(NSString *)meId {
    _meId = meId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:meId
                     forKey:kMEID];
    [userDefaults synchronize];
}

@end
