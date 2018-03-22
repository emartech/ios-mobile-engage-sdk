//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSDeviceInfo.h>
#import <CoreSDK/EMSRequestModel.h>
#import <CoreSDK/EMSAuthentication.h>
#import <CoreSDK/NSDate+EMSCore.h>
#import "MERequestFactory.h"
#import "MERequestContext.h"
#import "MobileEngageVersion.h"
#import "NSData+MobileEngine.h"
#import "MENotification.h"
#import "MEExperimental.h"

@implementation MERequestFactory

+ (EMSRequestModel *)createLoginRequestWithPushToken:(NSData *)pushToken
                                      requestContext:(MERequestContext *)requestContext {
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
                                           if (pushToken) {
                                               payload[@"push_token"] = [pushToken deviceTokenString];
                                           } else {
                                               payload[@"push_token"] = @NO;
                                           }
                                       } requestContext:requestContext];

    if ([requestContext.lastAppLoginPayload isEqual:requestModel.payload]) {
        requestModel = [self requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"
                                          method:HTTPMethodPOST
                          additionalPayloadBlock:nil requestContext:requestContext];
    } else {
        requestContext.lastAppLoginPayload = requestModel.payload;
    }
    return requestModel;
}

+ (EMSRequestModel *)createAppLogoutRequestWithRequestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [MERequestFactory requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout"
                                                                   method:HTTPMethodPOST
                                                   additionalPayloadBlock:nil
                                                           requestContext:requestContext];
    return requestModel;
}

+ (EMSRequestModel *)createTrackMessageOpenRequestWithNotification:(MENotification *)inboxMessage
                                                    requestContext:(MERequestContext *)requestContext {
    return [MERequestFactory requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                          method:HTTPMethodPOST
                          additionalPayloadBlock:^(NSMutableDictionary *payload) {
                              payload[@"sid"] = inboxMessage.sid;
                              payload[@"source"] = @"inbox";
                          } requestContext:requestContext];
}
+ (EMSRequestModel *)createTrackMessageOpenRequestWithMessageId:(NSString *)messageId

                                                 requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel;
    if (messageId) {
        requestModel = [MERequestFactory requestModelWithUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"
                                                      method:HTTPMethodPOST
                                      additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                          payload[@"sid"] = messageId;
                                      } requestContext:requestContext];
    } else {
        requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
        }];
    }

    return requestModel;
}

+ (EMSRequestModel *)createTrackCustomEventRequestWithEventName:(NSString *)eventName
                                                eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                 requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel;
    if (![MEExperimental isFeatureEnabled:INAPP_MESSAGING]) {
        requestModel = [MERequestFactory requestModelWithUrl:[NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName]
                                                      method:HTTPMethodPOST
                                      additionalPayloadBlock:^(NSMutableDictionary *payload) {
                                          payload[@"attributes"] = eventAttributes;
                                      } requestContext:requestContext];
    } else {
        requestModel = [MERequestFactory createCustomEventModelWithEventName:eventName
                                                             eventAttributes:eventAttributes
                                                                        type:@"custom"
                                                              requestContext:requestContext];
    }
    return requestModel;
}

+ (EMSRequestModel *)createCustomEventModelWithEventName:(NSString *)eventName
                                         eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                                                    type:(NSString *)type
                                          requestContext:(MERequestContext *)requestContext {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setMethod:HTTPMethodPOST];
        [builder setUrl:[NSString stringWithFormat:@"https://mobile-events.eservice.emarsys.net/v3/devices/%@/events", requestContext.meId]];
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"clicks"] = @[];
        payload[@"viewed_messages"] = @[];
        payload[@"hardware_id"] = [EMSDeviceInfo hardwareId];

        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                @"type": type,
                @"name": eventName,
                @"timestamp": [[requestContext.timestampProvider provideTimestamp] stringValueInUTC]}];

        if (eventAttributes) {
            event[@"attributes"] = eventAttributes;
        }

        payload[@"events"] = @[event];
        NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
        if (requestContext.meId) {
            mutableHeaders[@"X-ME-ID"] = requestContext.meId;
        }
        if (requestContext.meIdSignature) {
            mutableHeaders[@"X-ME-ID-SIGNATURE"] = requestContext.meIdSignature;
        }
        mutableHeaders[@"X-ME-APPLICATIONCODE"] = requestContext.config.applicationCode;
        [builder setHeaders:mutableHeaders];

        [builder setPayload:payload];
    }];
}

+ (EMSRequestModel *)createTrackDeepLinkRequestWithTrackingId:(NSString *)trackingId {
    NSString *userAgent = [NSString stringWithFormat:@"Mobile Engage SDK %@ %@ %@", MOBILEENGAGE_SDK_VERSION, [EMSDeviceInfo deviceType], [EMSDeviceInfo osVersion]];
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setMethod:HTTPMethodPOST];
        [builder setUrl:@"https://deep-link.eservice.emarsys.net/api/clicks"];
        [builder setHeaders:@{@"User-Agent": userAgent}];
        [builder setPayload:@{@"ems_dl": trackingId}];
    }];
}

+ (EMSRequestModel *)requestModelWithUrl:(NSString *)url
                                  method:(HTTPMethod)method
                  additionalPayloadBlock:(void (^)(NSMutableDictionary *payload))payloadBlock
                          requestContext:(MERequestContext *)requestContext {
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:url];
        [builder setMethod:method];
        NSMutableDictionary *payload = [@{
                @"application_id": requestContext.config.applicationCode,
                @"hardware_id": [EMSDeviceInfo hardwareId]
        } mutableCopy];

        if (requestContext.lastAppLoginParameters.contactFieldId && requestContext.lastAppLoginParameters.contactFieldValue) {
            payload[@"contact_field_id"] = requestContext.lastAppLoginParameters.contactFieldId;
            payload[@"contact_field_value"] = requestContext.lastAppLoginParameters.contactFieldValue;
        }

        if (payloadBlock) {
            payloadBlock(payload);
        }

        [builder setPayload:payload];
        [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:requestContext.config.applicationCode
                                                                                      password:requestContext.config.applicationPassword]}];
    }];
    return requestModel;
}

@end