#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MobileEngageInternal.h"
#import "MobileEngageInternal+Private.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"
#import "EMSAuthentication.h"
#import "EMSDeviceInfo.h"
#import "MobileEngageVersion.h"
#import "KiwiMacros.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

static NSString *const kAppId = @"kAppId";

MobileEngageInternal *_mobileEngage;

SPEC_BEGIN(PublicInterfaceTest)

    registerMatchers(@"EMS");

    beforeEach(^{
        _mobileEngage = [MobileEngageInternal new];
        [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                   error:nil];
    });

    id (^requestManagerMock)() = ^id() {
        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";
        NSDictionary *additionalHeaders = @{
                @"Authorization": [EMSAuthentication createBasicAuthWithUsername:applicationCode
                                                                        password:applicationPassword],
                @"Content-Type": @"application/json",
                @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION
        };
        id requestManager = [EMSRequestManager mock];
        [[requestManager should] receive:@selector(setAdditionalHeaders:)
                           withArguments:additionalHeaders];

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationCode:applicationCode
                                   applicationPassword:applicationPassword];
        }];

        [_mobileEngage setupWithRequestManager:requestManager
                                        config:config
                                 launchOptions:nil];
        return requestManager;
    };

    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    describe(@"setupWithConfig:launchOptions:", ^{
        it(@"should setup the RequestManager with base64 auth header", ^{
            requestManagerMock();
        });
    });

    describe(@"setPushToken:", ^{
        it(@"should call appLogin with lastAppLogin parameters", ^{
            NSData *deviceToken = [NSData new];
            [[_mobileEngage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)
                                  withCount:1
                                  arguments:nil, nil, nil];

            _mobileEngage.lastAppLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:nil contactFieldValue:nil];
            [_mobileEngage setPushToken:deviceToken];
        });

        it(@"should call appLogin with lastAppLogin parameters when there are previous values", ^{
            NSData *deviceToken = [NSData new];
            [[_mobileEngage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)
                                  withCount:1
                                  arguments:@12, @"23", nil];

            _mobileEngage.lastAppLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@12 contactFieldValue:@"23"];
            [_mobileEngage setPushToken:deviceToken];
        });

        it(@"appLogin should save last anonymous AppLogin parameters", ^{
            [[requestManagerMock() should] receive:@selector(submit:)];
            [_mobileEngage appLogin];
            [[_mobileEngage.lastAppLoginParameters shouldNot] beNil];
            [[_mobileEngage.lastAppLoginParameters.contactFieldId should] beNil];
            [[_mobileEngage.lastAppLoginParameters.contactFieldValue should] beNil];
        });

        it(@"appLogin should save last AppLogin parameters", ^{
            [[requestManagerMock() should] receive:@selector(submit:)];
            [_mobileEngage appLoginWithContactFieldId:@42 contactFieldValue:@"99"];
            [[_mobileEngage.lastAppLoginParameters shouldNot] beNil];
            [[_mobileEngage.lastAppLoginParameters.contactFieldId should] equal:@42];
            [[_mobileEngage.lastAppLoginParameters.contactFieldValue should] equal:@"99"];
        });

        it(@"should not call appLogin with setPushToken when there was no previous appLogin call", ^{
            NSData *deviceToken = [NSData new];
            [[_mobileEngage shouldNot] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)];
            [_mobileEngage setPushToken:deviceToken];
        });
    });


    describe(@"anonymous appLogin", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            NSString *uuid = [_mobileEngage appLogin];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            NSString *uuid = [_mobileEngage appLogin];
            EMSRequestModel *actualModel = spy.argument;
            [[uuid should] equal:actualModel.requestId];
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();
            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage appLogin];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });


    });

    describe(@"appLoginWithContactFieldId:contactFieldValue:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            NSString *uuid = [_mobileEngage appLoginWithContactFieldId:@0
                                                     contactFieldValue:@"contactFieldValue"];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            NSString *uuid = [_mobileEngage appLoginWithContactFieldId:@0
                                                     contactFieldValue:@"contactFieldValue"];
            EMSRequestModel *actualModel = spy.argument;
            [[uuid should] equal:actualModel.requestId];
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();
            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];
            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

    describe(@"applogout", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage appLogout];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            NSString *uuid = [_mobileEngage appLogout];

            EMSRequestModel *actualModel = spy.argument;
            [[uuid should] equal:actualModel.requestId];
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();
            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage appLogout];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });

        it(@"should clear lastAppLoginParameters", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)];

            [_mobileEngage setLastAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:@123456789
                                                                                      contactFieldValue:@"contactFieldValue"]];
            [_mobileEngage appLogout];
            [[_mobileEngage.lastAppLoginParameters should] beNil];
        });

    });

    describe(@"trackMessageOpenWithUserInfo:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            EMSRequestModel *actualModel = spy.argument;
            [[uuid should] equal:actualModel.requestId];
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();

            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"123456789"
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

    describe(@"trackMessageOpenWithInboxMessage:", ^{
        it(@"should throw exception when parameter is nil", ^{
            @try {
                [_mobileEngage trackMessageOpenWithInboxMessage:nil];
                fail(@"Expected Exception when inboxMessage is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();

            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"testID",
                    @"source": @"inbox"
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            MENotification *message = [MENotification new];
            message.sid = @"testID";
            [_mobileEngage trackMessageOpenWithInboxMessage:message];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });

        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();

            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"source": @"inbox"
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            MENotification *message = [MENotification new];
            message.sid = @"valueOfSid";
            [_mobileEngage trackMessageOpenWithInboxMessage:message];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });

        it(@"should return with the requestModel's requestID", ^{
            id requestManager = requestManagerMock();

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            MENotification *message = [MENotification new];
            message.sid = @"valueOfSid";
            NSString *requestID = [_mobileEngage trackMessageOpenWithInboxMessage:message];

            EMSRequestModel *actualModel = spy.argument;
            [[requestID should] equal:actualModel.requestId];
        });

        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            MENotification *message = [MENotification new];
            message.sid = @"testID";
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            NSString *uuid = [_mobileEngage trackMessageOpenWithInboxMessage:message];

            [[uuid shouldNot] beNil];
        });
    });

    describe(@"trackCustomEvent:eventAttributes:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage trackCustomEvent:@""
                                             eventAttributes:@{}];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            NSString *uuid = [_mobileEngage trackCustomEvent:@""
                                             eventAttributes:@{}];

            EMSRequestModel *actualModel = spy.argument;
            [[uuid should] equal:actualModel.requestId];
        });

        it(@"should throw exception when eventName is nil", ^{
            @try {
                [_mobileEngage trackCustomEvent:nil
                                eventAttributes:@{}];
                fail(@"Expected Exception when eventName is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should submit a corresponding RequestModel, when eventAttributes are set", ^{
            id requestManager = requestManagerMock();

            NSString *eventName = @"testEventName";
            NSDictionary *eventAttributes = @{@"someKey": @"someValue"};

            NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"attributes": eventAttributes
            };

            EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName], payload);

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage trackCustomEvent:eventName
                            eventAttributes:eventAttributes];
            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });


        it(@"should submit a corresponding RequestModel, when eventAttributes are missing", ^{
            id requestManager = requestManagerMock();

            NSString *eventName = @"testEventName";

            NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
            };

            EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName], payload);

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];
            [_mobileEngage trackCustomEvent:eventName
                            eventAttributes:nil];
            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

SPEC_END
