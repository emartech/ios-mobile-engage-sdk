//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import <CoreSDK/EMSRequestManager.h>
#import <CoreSDK/EMSAuthentication.h>
#import <CoreSDK/EMSRequestModelBuilder.h>
#import <CoreSDK/EMSDeviceInfo.h>
#import <CoreSDK/EMSRequestModel.h>
#import "MobileEngageStatusDelegate.h"
#import "MEConfig.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "MobileEngageVersion.h"

@interface MobileEngageInternal ()

typedef void (^MESuccessBlock)(NSString *requestId);

typedef void (^MEErrorBlock)(NSString *requestId, NSError *error);

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MEConfig *config;
@property(nonatomic, strong) NSData *pushToken;
@property(nonatomic, strong) MESuccessBlock successBlock;
@property(nonatomic, strong) MEErrorBlock errorBlock;

@end

@implementation MobileEngageInternal

- (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions {
    _requestManager = requestManager;
    _config = config;

    __weak typeof(self) weakSelf = self;
    _successBlock = ^(NSString *requestId) {
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

    NSDictionary<NSString *, NSString *> *additionalHeaders = @{
            @"Authorization": [EMSAuthentication createBasicAuthWithUsername:config.applicationId
                                                                    password:config.applicationSecret],
            @"Content-Type": @"application/json",
            @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION
    };
    [requestManager setAdditionalHeaders:additionalHeaders];
}

- (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    [self setupWithRequestManager:[EMSRequestManager new]
                           config:config
                    launchOptions:launchOptions];
}

- (NSString *)appLogin {
    return [self appLoginWithContactFieldId:nil
                          contactFieldValue:nil];
}

- (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"];
        [builder setMethod:HTTPMethodPOST];
        NSMutableDictionary *payload = [@{
                @"application_id": self.config.applicationId,
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
        if (self.pushToken) {
            payload[@"push_token"] = self.pushToken;
        } else {
            payload[@"push_token"] = @NO;
        }
        if (contactFieldId && contactFieldValue) {
            payload[@"contact_field_id"] = contactFieldId;
            payload[@"contact_field_value"] = contactFieldValue;
        }
        [builder setPayload:payload];
    }];

    [self.requestManager submit:requestModel
                   successBlock:self.successBlock
                     errorBlock:self.errorBlock];
    return requestModel.requestId;
}

- (NSString *)appLogout {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout"];
        [builder setMethod:HTTPMethodPOST];
        [builder setPayload:@{
                @"application_id": self.config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId],
        }];
    }];
    [self.requestManager submit:requestModel
                   successBlock:self.successBlock
                     errorBlock:self.errorBlock];
    return requestModel.requestId;
}

- (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSString *requestId;
    NSString *messageId = [userInfo messageId];
    if (messageId) {
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:@{
                    @"application_id": self.config.applicationId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": messageId
            }];
        }];
        [self.requestManager submit:requestModel
                       successBlock:self.successBlock
                         errorBlock:self.errorBlock];
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

- (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    NSParameterAssert(eventName);

    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName]];
        [builder setMethod:HTTPMethodPOST];
        NSMutableDictionary *payload = [@{
                @"application_id": self.config.applicationId,
                @"hardware_id": [EMSDeviceInfo hardwareId]
        } mutableCopy];
        if (eventAttributes) {
            payload[@"attributes"] = eventAttributes;
        }
        [builder setPayload:payload];
    }];
    [self.requestManager submit:requestModel
                   successBlock:self.successBlock
                     errorBlock:self.errorBlock];
    return requestModel.requestId;
}

@end
