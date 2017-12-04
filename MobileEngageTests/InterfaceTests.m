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
#import "FakeRequestManager.h"
#import "EMSResponseModel.h"
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MobileEngageInternal+Test.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

static NSString *const kAppId = @"kAppId";
static NSString *const kAppSecret = @"kAppSecret";

MobileEngageInternal *_mobileEngage;

SPEC_BEGIN(PublicInterfaceTest)

    registerMatchers(@"EMS");

    beforeEach(^{
        _mobileEngage = [MobileEngageInternal new];
        [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                   error:nil];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
        [userDefaults setObject:nil forKey:kMEID];
        [userDefaults setObject:nil forKey:kLastAppLoginPayload];
        [userDefaults synchronize];
    });

    id (^requestManagerMock)() = ^id() {
        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";
        NSDictionary *additionalHeaders = @{
                @"Authorization": [EMSAuthentication createBasicAuthWithUsername:applicationCode
                                                                        password:applicationPassword],
                @"Content-Type": @"application/json",
                @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION,
                @"X-MOBILEENGAGE-SDK-MODE": @"debug"
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

        it(@"should register MEIDResponseHandler", ^{
            requestManagerMock();

            BOOL registered = NO;
            for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                    registered = YES;
                }
            }

            [[theValue(registered) should] beYes];
        });

        it(@"should register MEIAMResponseHandler", ^{
            requestManagerMock();

            BOOL registered = NO;
            for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                    registered = YES;
                }
            }

            [[theValue(registered) should] beYes];
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

        it(@"appLogin should save the MEID returned in the response", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:kAppId
                                       applicationPassword:kAppSecret];
            }];
            MobileEngageInternal *internal = [MobileEngageInternal new];
            [internal setupWithConfig:config
                        launchOptions:nil];
            FakeRequestManager *fakeRequestManager = [FakeRequestManager managerWithSuccessBlock:internal.successBlock
                                                                                      errorBlock:internal.errorBlock];
            internal.requestManager = fakeRequestManager;

            NSString *meId = @"nr4io3rn2o3rn";
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": meId} options:0 error:nil];
            fakeRequestManager.responseModels = [@[[[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:data]] mutableCopy];

            [internal appLogin];

            [fakeRequestManager waitForAllExpectations];

            [[expectFutureValue(internal.meId) shouldEventually] equal:meId];
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

    describe(@"multiple applogin calls", ^{

        it(@"should not result in multiple applogin requests even if the payload is the same", ^{
            FakeRequestManager *requestManager = [FakeRequestManager new];
            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];

            EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
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


            EMSRequestModel *secondModel = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"], @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"
            });


            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];

            [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
            [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
        });

        it(@"should result in multiple applogin requests if the payload is not the same", ^{
            FakeRequestManager *requestManager = [FakeRequestManager new];
            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];

            EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
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


            EMSRequestModel *secondModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"something",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
            });


            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"something"];

            [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
            [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
        });

        it(@"should result in multiple applogin requests if the payload is the same size", ^{
            FakeRequestManager *requestManager = [FakeRequestManager new];
            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];

            EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"contactFieldValue1",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
            });


            EMSRequestModel *secondModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"contactFieldValue2",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
            });


            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"contactFieldValue1"];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"contactFieldValue2"];

            [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
            [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
        });

        it(@"should not result in multiple applogin requests if the payload is the same, even if MobileEngage is re-initialized", ^{
            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            FakeRequestManager *requestManager = [FakeRequestManager new];
            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];

            EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
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


            EMSRequestModel *secondModel = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"], @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @0,
                    @"contact_field_value": @"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"
            });


            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];

            _mobileEngage = [MobileEngageInternal new];
            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];

            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"vadaszRepulogepAnyahajoKabinHajtogatoKeziKeszulek"];

            [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
            [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
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

        it(@"should submit a corresponding RequestModel if there is no saved applogin parameters", ^{
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

        it(@"should submit a corresponding RequestModel if there is saved applogin parameters", ^{
            id requestManager = requestManagerMock();
            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @123456789,
                    @"contact_field_value": @"contactFieldValue"
            });

            [[requestManager should] receive:@selector(submit:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                        atIndex:0];

            [_mobileEngage setLastAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:@123456789
                                                                                      contactFieldValue:@"contactFieldValue"]];
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

        it(@"should clear lastAppLoginPayload", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:)];

            [_mobileEngage setLastAppLoginPayload:@{@"t" : @"v"}];
            [_mobileEngage appLogout];
            [[_mobileEngage.lastAppLoginPayload should] beNil];
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

        it(@"should submit a corresponding RequestModel when there is no contact_field_id and contact_field_value", ^{
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

        it(@"should submit a corresponding RequestModel when there are contact_field_id and contact_field_value", ^{
            id requestManager = requestManagerMock();
            MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                        contactFieldValue:@"contactFieldValue"];

            [_mobileEngage stub:@selector(lastAppLoginParameters)
                      andReturn:appLoginParameters];

            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"contactFieldValue",
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

        it(@"should submit a corresponding RequestModel when there is no contact_field_id and contact_field_value", ^{
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

        it(@"should submit a corresponding RequestModel when there are contact_field_id and contact_field_value", ^{
            id requestManager = requestManagerMock();

            MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                        contactFieldValue:@"contactFieldValue"];

            [_mobileEngage stub:@selector(lastAppLoginParameters)
                      andReturn:appLoginParameters];

            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"contact_field_id": @3,
                    @"contact_field_value": @"contactFieldValue",
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

            id timeStampProviderMock = [EMSTimestampProvider mock];
            NSNumber *timeStamp = @42;
            [[timeStampProviderMock should] receive:@selector(currentTimeStamp) andReturn:timeStamp withCountAtLeast:0];
            _mobileEngage.timestampProvider = timeStampProviderMock;

            NSString *meId = @"testMeId";
            _mobileEngage.meId = meId;
            NSString *eventName = @"testEventName";
            NSDictionary *eventAttributes = @{@"someKey": @"someValue"};

            NSDictionary *payload = @{
                    @"clicks": @[],
                    @"viewed_messages": @[],
                    @"events": @[
                            @{
                                    @"type": @"custom",
                                    @"id": eventName,
                                    @"attributes": eventAttributes,
                                    @"timestamp": timeStamp
                            }
                    ]
            };

            EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://ems-me-deviceevent.herokuapp.com/v3/devices/%@/events", meId], payload);

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

            id timeStampProviderMock = [EMSTimestampProvider mock];
            NSNumber *timeStamp = @42;
            [[timeStampProviderMock should] receive:@selector(currentTimeStamp) andReturn:timeStamp withCountAtLeast:0];
            _mobileEngage.timestampProvider = timeStampProviderMock;

            NSString *meId = @"testMeId";
            _mobileEngage.meId = meId;
            NSString *eventName = @"testEventName";

            NSDictionary *payload = @{
                    @"clicks": @[],
                    @"viewed_messages": @[],
                    @"events": @[
                            @{
                                    @"type": @"custom",
                                    @"id": eventName,
                                    @"timestamp": timeStamp
                            }
                    ]
            };

            EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://ems-me-deviceevent.herokuapp.com/v3/devices/%@/events", meId], payload);

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

    describe(@"meID", ^{

        it(@"should store the meID in userDefaults when the setter invoked", ^{
            NSString *meID = @"meIDValue";

            [_mobileEngage setMeId:meID];

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
            NSString *returnedValue = [userDefaults stringForKey:kMEID];

            [[returnedValue should] equal:meID];
        });

        it(@"should load the stored value when setup called on MobileEngageInternal", ^{
            NSString *meID = @"StoredValueOfMobileEngageId";

            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
            [userDefaults setObject:meID
                             forKey:kMEID];
            [userDefaults synchronize];

            [_mobileEngage setupWithConfig:config
                             launchOptions:nil];

            [[_mobileEngage.meId should] equal:meID];
        });

        it(@"should be cleared from userdefaults on logout", ^{
            NSString *meID = @"NotNil";

            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];
            [_mobileEngage setupWithConfig:config
                             launchOptions:nil];

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
            [userDefaults setObject:meID
                             forKey:kMEID];
            [userDefaults synchronize];

            [_mobileEngage appLogout];

            [[_mobileEngage.meId should] beNil];
        });

    });

SPEC_END
