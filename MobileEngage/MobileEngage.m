//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngage.h"
#import "MEConfig.h"
#import "MobileEngageStatusDelegate.h"
#import "NSDictionary+MobileEngage.h"
#import <CoreSDK/EMSRequestManager.h>
#import <CoreSDK/EMSAuthentication.h>
#import <CoreSDK/EMSDeviceInfo.h>
#import <CoreSDK/EMSRequestModel.h>
#import <CoreSDK/EMSRequestModelBuilder.h>
#import <CoreSDK/NSError+EMSCore.h>

@implementation MobileEngage

static id <MobileEngageStatusDelegate> _statusDelegate;
static EMSRequestManager *_requestManager;
static MEConfig *_config;
static NSData *_pushToken;

void (^ const successBlock)(NSString *)=^(NSString *requestId) {
    if ([_statusDelegate respondsToSelector:@selector(mobileEngageLogReceivedWithEventId:log:)]) {
        [_statusDelegate mobileEngageLogReceivedWithEventId:requestId
                                                        log:@"Success"];
    }
};

void (^ const errorBlock)(NSString *, NSError *)=^(NSString *requestId, NSError *error) {
    if ([_statusDelegate respondsToSelector:@selector(mobileEngageErrorHappenedWithEventId:error:)]) {
        [_statusDelegate mobileEngageErrorHappenedWithEventId:requestId
                                                        error:error];
    }
};

+ (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions {
    _requestManager = requestManager;
    _config = config;

    NSDictionary<NSString *, NSString *> *additionalHeaders = @{
            @"Authorization": [EMSAuthentication createBasicAuthWithUsername:config.applicationId
                                                                    password:config.applicationSecret]
    };

    [requestManager setAdditionalHeaders:additionalHeaders];
}

+ (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    [self setupWithRequestManager:[EMSRequestManager new]
                           config:config
                    launchOptions:launchOptions];
}

+ (NSString *)appLogin {
    return [MobileEngage appLoginWithContactFieldId:nil
                                  contactFieldValue:nil];
}

+ (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"];
        [builder setMethod:HTTPMethodPOST];
        NSMutableDictionary *payload = [@{
                @"application_id": _config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId],
                @"platform": @"ios",
                @"language": [EMSDeviceInfo languageCode],
                @"timezone": [EMSDeviceInfo timeZone],
                @"device_model": [EMSDeviceInfo deviceModel],
                @"os_version": [EMSDeviceInfo osVersion]
        } mutableCopy];
        NSString *appVersion = [EMSDeviceInfo applicationVersion];
        if (appVersion) {
            payload[@"application_version"] = appVersion;
        }
        if (_pushToken) {
            payload[@"push_token"] = _pushToken;
        }
        if (contactFieldId && contactFieldValue) {
            payload[@"contact_field_id"] = contactFieldId;
            payload[@"contact_field_value"] = contactFieldValue;
        }
        [builder setPayload:payload];
    }];

    [_requestManager submit:requestModel
               successBlock:successBlock
                 errorBlock:errorBlock];
    return requestModel.requestId;
}

+ (NSString *)appLogout {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout"];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:@{
                @"application_id": _config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId],
        }];
    }];
    [_requestManager submit:requestModel
               successBlock:successBlock
                 errorBlock:errorBlock];
    return requestModel.requestId;
}

+ (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSString *requestId;
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:@{
                    @"application_id": _config.applicationId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": messageId
            }];
        }];
        [_requestManager submit:requestModel
                   successBlock:successBlock
                     errorBlock:errorBlock];
        requestId = [requestModel requestId];
    } else {
        errorBlock(nil, [NSError errorWithCode:1
                          localizedDescription:@"Missing messageId"]);
    }
    return requestId;

}

+ (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName]];
        [builder setMethod:HTTPMethodPOST];
        NSMutableDictionary *payload = [@{
                @"application_id": _config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId]
        } mutableCopy];
        if (eventAttributes) {
            payload[@"attributes"] = eventAttributes;
        }
        [builder setPayload:payload];
    }];
    [_requestManager submit:requestModel
               successBlock:successBlock
                 errorBlock:errorBlock];
    return requestModel.requestId;
}

+ (void)setStatusDelegate:(id <MobileEngageStatusDelegate>)statusDelegate {
    _statusDelegate = statusDelegate;
}

+ (id <MobileEngageStatusDelegate>)statusDelegate {
    return _statusDelegate;
}

@end
