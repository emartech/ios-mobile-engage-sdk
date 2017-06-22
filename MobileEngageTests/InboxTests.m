#import "Kiwi.h"
#import "MobileEngage.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSDeviceInfo.h"
#import "MEDefaultHeaders.h"
#import "MEAppLoginParameters.h"
#import "FakeRestClient.h"
#import "MEInbox+Private.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(InboxTests)

    registerMatchers(@"EMS");

    NSString *applicationCode = kAppId;
    NSString *applicationPassword = @"appSecret";
    NSNumber *contactFieldId = @3;
    NSString *contactFieldValue = @"valueOfContactField";

    MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
        [builder setCredentialsWithApplicationCode:applicationCode
                               applicationPassword:applicationPassword];
    }];

    id (^inboxWithParameters)(EMSRESTClient *restClient, BOOL withApploginParameters) = ^id(EMSRESTClient *restClient, BOOL withApploginParameters) {
        MEInbox *inbox = [[MEInbox alloc] initWithRestClient:restClient
                                                      config:config];
        if (withApploginParameters) {
            [inbox setAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:contactFieldId
                                                                          contactFieldValue:contactFieldValue]];
        }
        return inbox;
    };

    id (^expectedHeaders)() = ^id() {
        NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:config];
        NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
        mutableFetchingHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
        mutableFetchingHeaders[@"x-ems-me-application-code"] = config.applicationCode;
        mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", contactFieldId];
        mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = contactFieldValue;
        return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
    };

    describe(@"inbox.fetchNotificationsWithResultBlock", ^{

        it(@"should not return nil in resultBlock", ^{
            __block MENotificationInboxStatus *result;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                result = inboxStatus;
            }                             errorBlock:^(NSError *error) {

            }];
            [[expectFutureValue(result) shouldNotEventually] beNil];
        });

        it(@"should run asyncronously", ^{
            __block MENotificationInboxStatus *result;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                result = inboxStatus;
            }                             errorBlock:^(NSError *error) {

            }];
            [[result should] beNil];
            [[expectFutureValue(result) shouldNotEventually] beNil];
        });

        it(@"should call EMSRestClient's executeTaskWithRequestModel: and parse the notifications correctly", ^{
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
            __block NSArray<MENotification *> *_notifications;
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                _notifications = inboxStatus.notifications;
            }                             errorBlock:^(NSError *error) {
                fail(@"errorblock invoked");
            }];

            NSDictionary *jsonResponse = @{@"notifications": @[
                    @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
                    @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
            ]};

            NSMutableArray<MENotification *> *notifications = [NSMutableArray array];
            for (NSDictionary *notificationDict in jsonResponse[@"notifications"]) {
                [notifications addObject:[[MENotification alloc] initWithNotificationDictionary:notificationDict]];
            }

            [[expectFutureValue(_notifications) shouldEventually] equal:notifications];
        });

        it(@"should call EMSRestClient's executeTaskWithRequestModel: with correct RequestModel", ^{
            EMSRESTClient *client = [EMSRESTClient mock];
            MEInbox *inbox = inboxWithParameters(client, YES);

            KWCaptureSpy *requestModelSpy = [client captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                    atIndex:0];
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                    }
                                          errorBlock:nil];

            EMSRequestModel *capturedRequestModel = requestModelSpy.argument;

            [[capturedRequestModel.url should] equal:[NSURL URLWithString:@"https://me-inbox.eservice.emarsys.net/api/notifications"]];
            [[capturedRequestModel.method should] equal:@"GET"];
            [[capturedRequestModel.headers should] equal:expectedHeaders()];
        });

        it(@"should throw an exception, when resultBlock is nil", ^{
            MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
            @try {
                [inbox fetchNotificationsWithResultBlock:nil
                                              errorBlock:^(NSError *error) {
                                              }];
                fail(@"Assertion doesn't called!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should invoke resultBlock on main thread", ^{
            __block NSNumber *onMainThread = @NO;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                if ([NSThread isMainThread]) {
                    onMainThread = @YES;
                }
            }                             errorBlock:nil];
            [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
        });

        it(@"should invoke errorBlock on main thread", ^{
            __block NSNumber *onMainThread = @NO;

            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], YES);
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                fail(@"resultblock invoked");
            }                             errorBlock:^(NSError *error) {
                if ([NSThread isMainThread]) {
                    onMainThread = @YES;
                }
            }];
            [[expectFutureValue(onMainThread) shouldEventually] equal:@YES];
        });

        it(@"should invoke errorBlock when applogin parameters are not available", ^{
            MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
            __block NSError *receivedError;
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                    errorBlock:^(NSError *error) {
                        receivedError = error;
                    }];
            [[expectFutureValue(receivedError) shouldNotEventually] beNil];
        });

        it(@"should not invoke errorBlock when there is no errorBlock with appLoginParameters", ^{
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], YES);
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                    errorBlock:nil];
        });

        it(@"should not invoke errorBlock when there is no errorBlock without appLoginParameters", ^{
            MEInbox *inbox = inboxWithParameters([EMSRESTClient mock], NO);
            [inbox fetchNotificationsWithResultBlock:^(MENotificationInboxStatus *inboxStatus) {
                        fail(@"resultblock invoked");
                    }
                                          errorBlock:nil];
        });
    });

    describe(@"inbox.resetBadgeCountWithSuccessBlock:errorBlock:", ^{

        it(@"should invoke restClient when appLoginParameters are set", ^{
            EMSRESTClient *restClientMock = [EMSRESTClient mock];
            [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

            MEInbox *inbox = inboxWithParameters(restClientMock, YES);

            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];
        });

        it(@"should not invoke restClient when appLoginParameters are not available", ^{
            EMSRESTClient *restClientMock = [EMSRESTClient mock];
            [[restClientMock shouldNot] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];

            MEInbox *inbox = inboxWithParameters(restClientMock, NO);

            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];
        });

        it(@"should invoke restClient with the correct requestModel", ^{
            EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodPOST];
                [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
                [builder setHeaders:expectedHeaders()];
            }];

            EMSRESTClient *restClientMock = [EMSRESTClient mock];
            [[restClientMock should] receive:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)];
            KWCaptureSpy *requestModelSpy = [restClientMock captureArgument:@selector(executeTaskWithRequestModel:successBlock:errorBlock:)
                                                                    atIndex:0];
            MEInbox *inbox = inboxWithParameters(restClientMock, YES);

            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];

            EMSRequestModel *capturedModel = requestModelSpy.argument;
            [[capturedModel should] beSimilarWithRequest:expectedRequestModel];
        });

        it(@"should invoke successBlock when success", ^{
            __block BOOL successBlockInvoked = NO;

            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
            [inbox resetBadgeCountWithSuccessBlock:^{
                        successBlockInvoked = YES;
                    }
                                        errorBlock:^(NSError *error) {
                                            fail(@"errorblock invoked");
                                        }];
            [[expectFutureValue(theValue(successBlockInvoked)) shouldEventually] beYes];
        });

        it(@"should invoke errorBlock when failure with apploginParameters", ^{
            __block NSError *_error;

            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], YES);
            [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                        errorBlock:^(NSError *error) {
                                            _error = error;
                                        }];
            [[_error shouldNotEventually] beNil];
        });

        it(@"should invoke errorBlock when failure without apploginParameters", ^{
            __block NSError *_error;

            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], NO);
            [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                        errorBlock:^(NSError *error) {
                                            _error = error;
                                        }];
            [[_error shouldNotEventually] beNil];
        });

        it(@"should not invoke successBlock when there is no successBlock", ^{
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);
            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];
        });

        it(@"should not invoke errorBlock when there is no errorBlock with apploginParameters", ^{
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], YES);
            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];
        });

        it(@"should not invoke errorBlock when there is no errorBlock without apploginParameters", ^{
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], NO);
            [inbox resetBadgeCountWithSuccessBlock:nil
                                        errorBlock:nil];
        });

        it(@"should invoke successBlock on main thread", ^{
            __block BOOL onMainThread = NO;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeSuccess], YES);

            [inbox resetBadgeCountWithSuccessBlock:^{
                        if ([NSThread isMainThread]) {
                            onMainThread = YES;
                        }
                    }
                                        errorBlock:^(NSError *error) {
                                            fail(@"errorblock invoked");
                                        }];
            [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
        });

        it(@"should invoke errorBlock on main thread", ^{
            __block BOOL onMainThread = NO;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], YES);

            [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                        errorBlock:^(NSError *error) {
                                            if ([NSThread isMainThread]) {
                                                onMainThread = YES;
                                            }
                                        }];
            [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
        });

        it(@"should invoke errorBlock on main thread when apploginParameters are not set", ^{
            __block BOOL onMainThread = NO;
            MEInbox *inbox = inboxWithParameters([[FakeRestClient alloc] initWithResultType:ResultTypeFailure], NO);

            [inbox resetBadgeCountWithSuccessBlock:^{
                        fail(@"successblock invoked");
                    }
                                        errorBlock:^(NSError *error) {
                                            if ([NSThread isMainThread]) {
                                                onMainThread = YES;
                                            }
                                        }];
            [[expectFutureValue(theValue(onMainThread)) shouldEventually] beYes];
        });
    });

    describe(@"inbox.resetBadgeCount", ^{
        it(@"should call resetBadgeCountWithSuccessBlock:errorBlock:", ^{
            MEInbox *inbox = [MEInbox new];
            __block NSNumber *resetCalled;
            [inbox stub:@selector(resetBadgeCountWithSuccessBlock:errorBlock:) withBlock:^id(NSArray *params) {
                resetCalled = @YES;
                return nil;
            }];

            [inbox resetBadgeCount];

            [[expectFutureValue(resetCalled) shouldNotEventually] beNil];
        });
    });


SPEC_END