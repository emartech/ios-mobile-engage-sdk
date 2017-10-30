#import "Kiwi.h"
#import "MEJSBridge.h"
#import <UserNotifications/UserNotifications.h>

MEJSBridge *_meJsBridge;
UIApplication *_applicationMock;

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

SPEC_BEGIN(MEJSBridgeTests)

    beforeEach(^{
        _meJsBridge = [MEJSBridge new];
    });

    describe(@"requestPushPermission", ^{

        beforeEach(^{
            _applicationMock = [UIApplication mock];
            [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
        });

        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application under iOS 10", ^{
                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[_applicationMock should] receive:@selector(registerUserNotificationSettings:) withArguments:any()];
                KWCaptureSpy *spy = [_applicationMock captureArgument:@selector(registerUserNotificationSettings:)
                                                              atIndex:0];

                [_meJsBridge requestPushPermission];
                UIUserNotificationSettings *notificationSettings = spy.argument;
                UIUserNotificationType type = notificationSettings.types;
                [[theValue(type) should] equal:theValue(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)];

            });
        }

        if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application when os version is greater or equal then iOS 10", ^{
                UNUserNotificationCenter *userNotificationCenterMock = [UNUserNotificationCenter mock];
                [[UNUserNotificationCenter should] receive:@selector(currentNotificationCenter) andReturn:userNotificationCenterMock];

                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[userNotificationCenterMock should] receive:@selector(requestAuthorizationWithOptions:completionHandler:) withArguments:any(), any()];

                KWCaptureSpy *spy = [userNotificationCenterMock captureArgument:@selector(requestAuthorizationWithOptions:completionHandler:)
                                                                        atIndex:0];
                [_meJsBridge requestPushPermission];

                [[spy.argument should] equal:theValue(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)];
            });
        }

    });

    describe(@"openExternalLink", ^{

        beforeEach(^{
            _applicationMock = [UIApplication mock];
            [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
        });

        it(@"should return false if link is not valid", ^{
            NSString *link = nil;

            [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(NO)];
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

            __block BOOL returnedContent;
            [_meJsBridge openExternalLink:link
                        completionHandler:^(BOOL success) {
                            returnedContent = success;
                            [exp fulfill];

                        }];

            [XCTWaiter waitForExpectations:@[exp]
                                   timeout:30];

            [[theValue(returnedContent) should] beNo];
        });


        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should open the link if it is valid below ios10", ^{
                NSString *link = @"https://www.google.com";

                _applicationMock = [UIApplication mock];
                [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];

                [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(YES)];
                [[_applicationMock should] receive:@selector(openURL:) withArguments:[NSURL URLWithString:link]];

                [_meJsBridge openExternalLink:link
                            completionHandler:^(BOOL success) {

                            }];
            });

            void (^testCompletionHandlerWithReturnValue)(BOOL returnValue) = ^void(BOOL expectedValue) {
                NSString *link = @"https://www.google.com";

                _applicationMock = [UIApplication mock];
                [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];

                [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(YES)];
                [[_applicationMock should] receive:@selector(openURL:) andReturn:theValue(expectedValue)];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];
                __block BOOL returnedValue;
                [_meJsBridge openExternalLink:link
                            completionHandler:^(BOOL success) {
                                returnedValue = success;
                                [exp fulfill];
                            }];

                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[theValue(returnedValue) should] equal:theValue(expectedValue)];
            };


            it(@"should call completion handler with YES in openURL completionHandler below ios10", ^{
                testCompletionHandlerWithReturnValue(YES);
            });

            it(@"should call completion handler with NO in openURL completionHandler below ios10", ^{
                testCompletionHandlerWithReturnValue(NO);
            });
        }

        if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should open the link if it is valid above ios10", ^{
                NSString *link = @"https://www.google.com";

                _applicationMock = [UIApplication mock];
                [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];

                [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(YES)];
                [[_applicationMock should] receive:@selector(openURL:options:completionHandler:) withArguments:[NSURL URLWithString:link], nil, any()];

                [_meJsBridge openExternalLink:link
                            completionHandler:^(BOOL success) {

                            }];
            });

            void (^testCompletionHandlerWithReturnValue)(BOOL returnValue) = ^void(BOOL expectedValue) {
                NSString *link = @"https://www.google.com";

                _applicationMock = [UIApplication mock];
                [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];

                [[_applicationMock should] receive:@selector(canOpenURL:) andReturn:theValue(YES)];
                [[_applicationMock should] receive:@selector(openURL:options:completionHandler:)];
                KWCaptureSpy *spy = [_applicationMock captureArgument:@selector(openURL:options:completionHandler:)
                                                              atIndex:2];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];
                __block BOOL returnedValue;
                [_meJsBridge openExternalLink:link
                            completionHandler:^(BOOL success) {
                                returnedValue = success;
                                [exp fulfill];
                            }];

                void (^completionBlock)(BOOL success) = spy.argument;
                completionBlock(expectedValue);

                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[theValue(returnedValue) should] equal:theValue(expectedValue)];
            };

            it(@"should call completion handler with YES in openURL completionHandler above ios10", ^{
                testCompletionHandlerWithReturnValue(YES);
            });

            it(@"should call completion handler with NO in openURL completionHandler above ios10", ^{
                testCompletionHandlerWithReturnValue(NO);
            });

        }

    });

SPEC_END