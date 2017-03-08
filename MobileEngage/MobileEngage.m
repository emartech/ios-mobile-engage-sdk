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

@implementation MobileEngage

static id <MobileEngageStatusDelegate> _statusDelegate;
static EMSRequestManager *_requestManager;
static MEConfig *_config;
static NSData *_pushToken;

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
               successBlock:nil
                 errorBlock:nil];
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
               successBlock:nil
                 errorBlock:nil];
    return requestModel.requestId;
}

+ (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:@{
                @"application_id": _config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId],
                @"sid": [NSDictionary messageIdFromUserInfo:userInfo]
        }];
    }];
    [_requestManager submit:requestModel
               successBlock:nil
                 errorBlock:nil];
    return requestModel.requestId;
}

+ (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);
    NSParameterAssert(eventAttributes);

    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName]];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:@{
                @"application_id": _config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId],
                @"attributes": eventAttributes
        }];
    }];
    [_requestManager submit:requestModel
               successBlock:nil
                 errorBlock:nil];
    return requestModel.requestId;
}

+ (void)setStatusDelegate:(id <MobileEngageStatusDelegate>)statusDelegate {
    _statusDelegate = statusDelegate;
}

+ (id <MobileEngageStatusDelegate>)statusDelegate {
    return _statusDelegate;
}

@end
