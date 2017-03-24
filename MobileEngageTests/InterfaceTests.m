#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MobileEngageInternal.h"
#import "MobileEngageInternal+Private.h"
#import "MobileEngageStatusDelegate.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"
#import "EMSAuthentication.h"
#import "EMSDeviceInfo.h"
#import "FakeRequestManager.h"
#import "FakeStatusDelegate.h"
#import "MobileEngageVersion.h"

static NSString *const kAppId = @"kAppId";

MobileEngageInternal *_mobileEngage;

SPEC_BEGIN(PublicInterfaceTest)

    registerMatchers(@"EMS");

    beforeAll(^{
        _mobileEngage = [MobileEngageInternal new];
    });

    id (^requestManagerMock)() = ^id() {
        NSString *applicationId = kAppId;
        NSString *applicationSecret = @"appSecret";
        NSDictionary *additionalHeaders = @{
                @"Authorization": [EMSAuthentication createBasicAuthWithUsername:applicationId
                                                                        password:applicationSecret],
                @"Content-Type": @"application/json",
                @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION
        };
        id requestManager = [EMSRequestManager mock];
        [[requestManager should] receive:@selector(setAdditionalHeaders:)
                           withArguments:additionalHeaders];

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationId:applicationId
                                   applicationSecret:applicationSecret];
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

    describe(@"anonymous appLogin", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];

            NSString *uuid = [_mobileEngage appLogin];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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
                    @"application_version" : @"1.0"
            });

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
                                                        atIndex:0];
            [_mobileEngage appLogin];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });


    });

    describe(@"appLoginWithContactFieldId:contactFieldValue:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];

            NSString *uuid = [_mobileEngage appLoginWithContactFieldId:@0
                                                     contactFieldValue:@"contactFieldValue"];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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
                    @"application_version" : @"1.0"
            });

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage appLogout];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
                                                        atIndex:0];
            [_mobileEngage appLogout];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

    describe(@"trackMessageOpenWithUserInfo:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
                                                        atIndex:0];
            [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

    describe(@"trackCustomEvent:eventAttributes:", ^{
        it(@"must not return with nil", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            NSString *uuid = [_mobileEngage trackCustomEvent:@""
                                             eventAttributes:@{}];
            [[uuid shouldNot] beNil];
        });

        it(@"should return with requestModel's requestId", ^{
            id requestManager = requestManagerMock();
            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
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

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), any(), any()];

            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
                                                        atIndex:0];
            [_mobileEngage trackCustomEvent:eventName
                            eventAttributes:nil];
            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

    describe(@"statusDelegate", ^{

        id (^statusDelegateMock)(ResponseType responseType) = ^id(ResponseType responseType) {
            FakeRequestManager *requestManager = [FakeRequestManager new];
            [requestManager setResponseType:responseType];

            NSString *applicationId = kAppId;
            NSString *applicationSecret = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:applicationId
                                       applicationSecret:applicationSecret];
            }];
            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];
            return [KWMock mockForProtocol:@protocol(MobileEngageStatusDelegate)];
        };

        it(@"should be called with logReceived when anonymousAppLogin is successful", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeSuccess);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLogin];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageLogReceivedWithEventId:log:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when anonymousAppLogin is failure", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLogin];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with logReceived when appLoginWithContact is successful", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeSuccess);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLoginWithContactFieldId:@123
                                                        contactFieldValue:@"contactValue"];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageLogReceivedWithEventId:log:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when appLoginWithContact is failure", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLoginWithContactFieldId:@123
                                                        contactFieldValue:@"contactValue"];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with logReceived when appLogout is successful", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeSuccess);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLogout];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageLogReceivedWithEventId:log:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when appLogout is failure", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage appLogout];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with logReceived when trackMessageOpenWithUserInfo is successful", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeSuccess);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageLogReceivedWithEventId:log:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when trackMessageOpenWithUserInfo is failure", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when trackMessageOpenWithUserInfo is called with missing messageId", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *messageId = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"no-sid\":\"123456789\"}"}];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:messageId, any()];
        });

        it(@"should be called with logReceived when trackCustomEvent is successful", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeSuccess);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage trackCustomEvent:@"event-name"
                                                eventAttributes:nil];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageLogReceivedWithEventId:log:)
                                             withCount:1
                                             arguments:eventId, any()];
        });

        it(@"should be called with errorHappened when trackCustomEvent is failure", ^{
            id statusDelegate = statusDelegateMock(ResponseTypeFailure);

            [_mobileEngage setStatusDelegate:statusDelegate];
            NSString *eventId = [_mobileEngage trackCustomEvent:@"event-name"
                                                eventAttributes:nil];

            [[statusDelegate shouldEventually] receive:@selector(mobileEngageErrorHappenedWithEventId:error:)
                                             withCount:1
                                             arguments:eventId, any()];
        });
    });

    describe(@"Main thread", ^{

        void (^setupWithResponseType)(ResponseType responseType) = ^void(ResponseType responseType) {
            FakeRequestManager *requestManager = [FakeRequestManager new];
            [requestManager setResponseType:responseType];

            NSString *applicationId = kAppId;
            NSString *applicationSecret = @"appSecret";
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:applicationId
                                       applicationSecret:applicationSecret];
            }];
            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:nil];
        };

        it(@"should be used for statusDelegate, when anonymous appLogin success happens", ^{
            setupWithResponseType(ResponseTypeSuccess);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLogin];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should be used for statusDelegate, when anonymous appLogin failure happens", ^{
            setupWithResponseType(ResponseTypeFailure);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLogin];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@1];
        });

        it(@"should be used for statusDelegate, when appLogin success happens", ^{
            setupWithResponseType(ResponseTypeSuccess);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"contactFieldValue"];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should be used for statusDelegate, when appLogin failure happens", ^{
            setupWithResponseType(ResponseTypeFailure);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLoginWithContactFieldId:@0
                                    contactFieldValue:@"contactFieldValue"];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@1];
        });

        it(@"should be used for statusDelegate, when appLogout success happens", ^{
            setupWithResponseType(ResponseTypeSuccess);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLogout];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should be used for statusDelegate, when appLogout failure happens", ^{
            setupWithResponseType(ResponseTypeFailure);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage appLogout];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@1];
        });

        it(@"should be used for statusDelegate, when messageOpen success happens", ^{
            setupWithResponseType(ResponseTypeSuccess);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should be used for statusDelegate, when messageOpen failure happens", ^{
            setupWithResponseType(ResponseTypeFailure);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@1];
        });

        it(@"should be used for statusDelegate, when messageOpen success happens", ^{
            setupWithResponseType(ResponseTypeSuccess);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage trackCustomEvent:@"eventName"
                            eventAttributes:nil];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should be used for statusDelegate, when messageOpen failure happens", ^{
            setupWithResponseType(ResponseTypeFailure);
            FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];

            [_mobileEngage setStatusDelegate:statusDelegate];
            [_mobileEngage trackCustomEvent:@"eventName"
                            eventAttributes:nil];

            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@1];
        });

    });

SPEC_END
