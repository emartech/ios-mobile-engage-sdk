//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"
#import <CoreSDK/EMSRequestModelBuilder.h>
#import <CoreSDK/EMSDeviceInfo.h>
#import "MobileEngageStatusDelegate.h"
#import "MEConfig.h"
#import "NSDictionary+MobileEngage.h"
#import "NSError+EMSCore.h"
#import "NSData+MobileEngine.h"
#import "MEDefaultHeaders.h"
#import "MobileEngageVersion.h"
#import <CoreSDK/EMSResponseModel.h>
#import "AbstractResponseHandler.h"
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEExperimental.h"
#import <CoreSDK/EMSRequestModelRepository.h>
#import "MERequestRepositoryProxy.h"
#import "MEButtonClickRepository.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"
#import "MEDisplayedIAMRepository.h"
#import "MEIAMCleanupResponseHandler.h"
#import <CoreSDK/EMSAuthentication.h>
#import "MENotificationCenterManager.h"
#import "MERequestContext.h"
#import <UIKit/UIKit.h>

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
    _requestContext = [MERequestContext new];
    _requestManager = requestManager;
    _config = config;
    [requestManager setAdditionalHeaders:[MEDefaultHeaders additionalHeadersWithConfig:self.config]];
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        _responseHandlers = @[
                [[MEIdResponseHandler alloc] initWithRequestContext:_requestContext],
                [MEIAMResponseHandler new],
                [[MEIAMCleanupResponseHandler alloc] initWithButtonClickRepository:[[MEButtonClickRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                              displayIamRepository:[[MEDisplayedIAMRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]]
        ];
    } else {
        _responseHandlers = @[];
    }
    _timestampProvider = [EMSTimestampProvider new];

    __weak typeof(self) weakSelf = self;
    [_notificationCenterManager addHandlerBlock:^{
        if (self.requestContext.meId != nil) {
            [weakSelf.requestManager submit:[weakSelf createCustomEventModel:@"app:start"
                                                             eventAttributes:nil
                                                                        type:@"internal"]];
        }
    }                           forNotification:UIApplicationDidBecomeActiveNotification];
}

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler {
    BOOL result = NO;
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSString *const webPageURL = userActivity.webpageURL.absoluteString;
        NSString *const queryNameDeepLink = @"ems_dl";
        NSURLQueryItem *queryItem = [self extractQueryItemFromUrl:webPageURL
                                                        queryName:queryNameDeepLink];
        if (queryItem) {
            result = YES;
            if (sourceHandler) {
                sourceHandler(webPageURL);
            }
            EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://deep-link.eservice.emarsys.net/api/clicks"];
                [builder setPayload:@{queryNameDeepLink: queryItem.value ? queryItem.value : @""}];
                [builder setMethod:HTTPMethodPOST];
            }];
            [self.requestManager submit:requestModel];
        }
    }
    return result;
}

- (NSURLQueryItem *)extractQueryItemFromUrl:(NSString *const)webPageURL
                                  queryName:(NSString *const)queryName {
    NSURLQueryItem *result;
    for (NSURLQueryItem *queryItem in [[NSURLComponents componentsWithString:webPageURL] queryItems]) {
        if ([queryItem.name isEqualToString:queryName]) {
            result = queryItem;
            break;
        }
    }
    return result;
}


- (void)trackInAppDisplay:(NSString *)campaignId {
    [self.requestManager submit:[self createCustomEventModel:@"inapp:viewed"
                                             eventAttributes:@{@"message_id": campaignId}
                                                        type:@"internal"]];
}

- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId {
    [self.requestManager submit:[self createCustomEventModel:@"inapp:click"
                                             eventAttributes:@{@"message_id": campaignId, @"button_id": buttonId}
                                                        type:@"internal"]];
}

- (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    [MEExperimental enableFeatures:config.experimentalFeatures];
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
    if ([MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        MERequestRepositoryProxy *requestRepository = [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]]
                                                                                                 buttonClickRepository:[[MEButtonClickRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                                                                displayedIAMRepository:[[MEDisplayedIAMRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]];
        [self setupWithRequestManager:[EMSRequestManager managerWithSuccessBlock:self.successBlock
                                                                      errorBlock:self.errorBlock
                                                               requestRepository:requestRepository]
                               config:config
                        launchOptions:launchOptions];
    } else {
        [self setupWithRequestManager:[EMSRequestManager managerWithSuccessBlock:self.successBlock
                                                                      errorBlock:self.errorBlock]
                               config:config
                        launchOptions:launchOptions];
    }

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

    if ([self.requestContext.lastAppLoginPayload isEqual:requestModel.payload]) {
        requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"
                                          method:HTTPMethodPOST
                          additionalPayloadBlock:nil];
    } else {
        self.requestContext.lastAppLoginPayload = requestModel.payload;
    }

    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (EMSRequestModel *)requestModelWithUrl:(NSString *)url
                                  method:(HTTPMethod)method
                  additionalPayloadBlock:(void (^)(NSMutableDictionary *payload))payloadBlock {
    __weak typeof(self) weakSelf = self;
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:url];
        [builder setMethod:method];
        NSMutableDictionary *payload = [@{
                @"application_id": weakSelf.config.applicationCode,
                @"hardware_id": [EMSDeviceInfo hardwareId]
        } mutableCopy];

        if (self.lastAppLoginParameters.contactFieldId && weakSelf.lastAppLoginParameters.contactFieldValue) {
            payload[@"contact_field_id"] = weakSelf.lastAppLoginParameters.contactFieldId;
            payload[@"contact_field_value"] = weakSelf.lastAppLoginParameters.contactFieldValue;
        }

        if (payloadBlock) {
            payloadBlock(payload);
        }

        [builder setPayload:payload];
        [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:weakSelf.config.applicationCode
                                                                                      password:weakSelf.config.applicationPassword]}];
    }];
    return requestModel;
}

- (NSString *)appLogout {
    EMSRequestModel *requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout" method:HTTPMethodPOST additionalPayloadBlock:nil];

    [self.requestManager submit:requestModel];
    self.lastAppLoginParameters = nil;
    self.requestContext.lastAppLoginPayload = nil;
    self.requestContext.meId = nil;
    self.requestContext.meIdSignature = nil;
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

    EMSRequestModel *requestModel = [self createCustomEventModel:eventName eventAttributes:eventAttributes type:@"custom"];

    [self.requestManager submit:requestModel];
    return requestModel.requestId;
}

- (EMSRequestModel *)createCustomEventModel:(NSString *)eventName eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes type:(NSString *)type {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setMethod:HTTPMethodPOST];
        [builder setUrl:[NSString stringWithFormat:@"https://mobile-events.eservice.emarsys.net/v3/devices/%@/events", self.requestContext.meId]];
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"clicks"] = @[];
        payload[@"viewed_messages"] = @[];
        payload[@"hardware_id"] = [EMSDeviceInfo hardwareId];

        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                @"type": type,
                @"name": eventName,
                @"timestamp": [self.timestampProvider currentTimestampInUTC]}];

        if (eventAttributes) {
            event[@"attributes"] = eventAttributes;
        }

        payload[@"events"] = @[event];
        NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
        if (self.requestContext.meId) {
            mutableHeaders[@"X-ME-ID"] = self.requestContext.meId;
        }
        if (self.requestContext.meIdSignature) {
            mutableHeaders[@"X-ME-ID-SIGNATURE"] = self.requestContext.meIdSignature;
        }
        mutableHeaders[@"X-ME-APPLICATIONCODE"] = self.config.applicationCode;
        [builder setHeaders:mutableHeaders];

        [builder setPayload:payload];
    }];
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

@end
