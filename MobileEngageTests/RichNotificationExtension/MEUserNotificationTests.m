#import "Kiwi.h"
#import "MobileEngage.h"
#import "MobileEngageInternal.h"
#import <UserNotifications/UNNotification.h>
#import <UserNotifications/UNNotificationResponse.h>
#import <UserNotifications/UNNotificationRequest.h>
#import <UserNotifications/UNNotificationContent.h>
#import "MEUserNotification.h"

SPEC_BEGIN(MEUserNotificationTests)
        if (@available(iOS 10.0, *)) {
            id (^notificationResponseWithUserInfoWithActionId)(NSDictionary *userInfo, NSString *actionId) = ^id(NSDictionary *userInfo, NSString *actionId) {
                UNNotificationResponse *response = [UNNotificationResponse mock];
                UNNotification *notification = [UNNotification mock];
                UNNotificationRequest *request = [UNNotificationRequest mock];
                UNNotificationContent *content = [UNNotificationContent mock];
                [response stub:@selector(notification) andReturn:notification];
                [response stub:@selector(actionIdentifier) andReturn:actionId];
                [notification stub:@selector(request) andReturn:request];
                [request stub:@selector(content) andReturn:content];
                [content stub:@selector(userInfo) andReturn:userInfo];
                return response;
            };

            id (^notificationResponseWithUserInfo)(NSDictionary *userInfo) = ^id(NSDictionary *userInfo) {
                return notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId");
            };

            describe(@"init", ^{
                it(@"should throw an exception when there is no application", ^{
                    @try {
                        [[MEUserNotification alloc] initWithApplication:nil
                                                   mobileEngageInternal:[MobileEngageInternal mock]];
                        fail(@"Expected Exception when application is nil!");
                    } @catch (NSException *exception) {
                        [[exception.reason should] equal:@"Invalid parameter not satisfying: application"];
                        [[theValue(exception) shouldNot] beNil];
                    }
                });

                it(@"should throw an exception when there is no mobileEngageInternal", ^{
                    @try {
                        [[MEUserNotification alloc] initWithApplication:[UIApplication mock]
                                                   mobileEngageInternal:nil];
                        fail(@"Expected Exception when mobileEngage is nil!");
                    } @catch (NSException *exception) {
                        [[exception.reason should] equal:@"Invalid parameter not satisfying: mobileEngage"];
                        [[theValue(exception) shouldNot] beNil];
                    }
                });
            });

            describe(@"userNotificationCenter:willPresentNotification:withCompletionHandler:", ^{

                it(@"should call the injected delegate's userNotificationCenter:willPresentNotification:withCompletionHandler: method", ^{
                    id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                    UNUserNotificationCenter *mockCenter = [UNUserNotificationCenter mock];
                    UNNotification *mockNotification = [UNNotification mock];
                    void (^ const completionHandler)(UNNotificationPresentationOptions)=^(UNNotificationPresentationOptions options) {
                    };

                    [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:) withArguments:mockCenter, mockNotification, completionHandler];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.delegate = userNotificationCenterDelegate;

                    [userNotification userNotificationCenter:mockCenter
                                     willPresentNotification:mockNotification
                                       withCompletionHandler:completionHandler];
                });

                it(@"should call completion handler with UNNotificationPresentationOptionAlert", ^{
                    MEUserNotification *userNotification = [MEUserNotification new];
                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    __block UNNotificationPresentationOptions _option;
                    [userNotification userNotificationCenter:nil
                                     willPresentNotification:nil
                                       withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                           _option = options;
                                           [exp fulfill];
                                       }];

                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp] timeout:5];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                    [[theValue(_option) should] equal:theValue(UNNotificationPresentationOptionAlert)];
                });

            });

            describe(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", ^{

                it(@"should call the injected delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: method", ^{
                    id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                    UNUserNotificationCenter *center = [UNUserNotificationCenter nullMock];
                    UNNotificationResponse *notificationResponse = [UNNotificationResponse nullMock];
                    void (^ const completionHandler)()=^{
                    };

                    [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) withArguments:center, notificationResponse, completionHandler];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.delegate = userNotificationCenterDelegate;

                    [userNotification userNotificationCenter:center
                              didReceiveNotificationResponse:notificationResponse
                                       withCompletionHandler:completionHandler];
                });

                it(@"should call completion handler", ^{
                    MEUserNotification *userNotification = [MEUserNotification new];
                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [userNotification userNotificationCenter:nil didReceiveNotificationResponse:nil withCompletionHandler:^{
                        [exp fulfill];
                    }];

                    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp] timeout:5];
                    [[theValue(result) should] equal:theValue(XCTWaiterResultCompleted)];
                });

                it(@"should call MobileEngage.notification.eventHandler with the defined eventName and payload if the action is type of MEAppEvent", ^{
                    id eventHandlerMock = [KWMock mockForProtocol:@protocol(MEEventHandler)];
                    NSString *eventName = @"testEventName";
                    NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                    [[eventHandlerMock should] receive:@selector(handleEvent:payload:) withArguments:eventName, payload];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.eventHandler = eventHandlerMock;

                    NSDictionary *userInfo = @{@"ems": @{
                        @"actions": @[
                            @{
                                @"id": @"uniqueId",
                                @"title": @"actionTitle",
                                @"type": @"MEAppEvent",
                                @"name": eventName,
                                @"payload": payload
                            }
                        ]}};

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [userNotification userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                    [XCTWaiter waitForExpectations:@[exp] timeout:5];
                });

                it(@"should not call MobileEngage.notification.eventHandler with the defined eventName and payload if the action is not MEAppEvent type", ^{
                    id eventHandlerMock = [KWMock mockForProtocol:@protocol(MEEventHandler)];
                    [[eventHandlerMock shouldNot] receive:@selector(handleEvent:payload:)];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.eventHandler = eventHandlerMock;

                    NSDictionary *userInfo = @{@"ems": @{
                        @"actions": @[
                            @{
                                @"id": @"uniqueId",
                                @"title": @"actionTitle",
                                @"type": @"someStuff",
                                @"name": @"testEventName",
                                @"payload": @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"}
                            }
                        ]}};

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [userNotification userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                    [XCTWaiter waitForExpectations:@[exp] timeout:5];
                });

                it(@"should call trackCustomEvent on MobileEngage with the defined eventName and payload if the action is type of MECustomEvent", ^{
                    NSString *eventName = @"testEventName";
                    NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                    MobileEngageInternal *mobileEngage = [MobileEngageInternal mock];

                    MEUserNotification *userNotification = [[MEUserNotification alloc] initWithApplication:[UIApplication mock]
                                                                                      mobileEngageInternal:mobileEngage];
                    NSDictionary *userInfo = @{@"ems": @{
                        @"actions": @[
                            @{
                                @"id": @"uniqueId",
                                @"title": @"actionTitle",
                                @"type": @"MECustomEvent",
                                @"name": eventName,
                                @"payload": payload
                            }
                        ]}};
                    [[mobileEngage should] receive:@selector(trackCustomEvent:eventAttributes:) withArguments:eventName, payload];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [userNotification userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                    [XCTWaiter waitForExpectations:@[exp] timeout:5];

                });

                it(@"should call mobileEngange with the correct action", ^{
                    MobileEngageInternal *mockMEInternal = [MobileEngageInternal nullMock];
                    MEUserNotification *userNotification = [[MEUserNotification alloc] initWithApplication:[UIApplication mock]
                                                                                      mobileEngageInternal:mockMEInternal];

                    NSDictionary *payload = @{@"key1": @"value1", @"key2": @"value2", @"key3": @"value3"};
                    NSString *eventName = @"eventName";
                    NSDictionary *userInfo = @{@"ems": @{@"actions": @[
                        @{
                            @"id": @"uniqueId",
                            @"title": @"actionTitle",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                        }, @{
                            @"id": @"uniqueId2",
                            @"title": @"actionTitle",
                            @"type": @"MECustomEvent",
                            @"name": eventName,
                            @"payload": payload
                        }
                    ]}};

                    [[mockMEInternal should] receive:@selector(trackCustomEvent:eventAttributes:) withArguments:eventName, payload];

                    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                    [userNotification userNotificationCenter:nil
                              didReceiveNotificationResponse:notificationResponseWithUserInfoWithActionId(userInfo, @"uniqueId2")
                                       withCompletionHandler:^{
                                           [exp fulfill];
                                       }];
                    [XCTWaiter waitForExpectations:@[exp] timeout:5];

                });

                if (@available(iOS 10.0, *)) {
                    it(@"should call openURL:options:completionHandler: with the defined url if the action is type of OpenExternalUrl", ^{
                        UIApplication *application = [UIApplication mock];
                        [[application should] receive:@selector(openURL:options:completionHandler:) withArguments:[NSURL URLWithString:@"https://www.emarsys.com"], @{}, kw_any()];

                        MEUserNotification *userNotification = [[MEUserNotification alloc] initWithApplication:application
                                                                                          mobileEngageInternal:[MobileEngageInternal mock]];
                        NSDictionary *userInfo = @{@"ems": @{@"actions": @[
                            @{
                                @"id": @"uniqueId",
                                @"title": @"actionTitle",
                                @"type": @"OpenExternalUrl",
                                @"url": @"https://www.emarsys.com"
                            }
                        ]}};

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                        [userNotification userNotificationCenter:nil
                                  didReceiveNotificationResponse:notificationResponseWithUserInfo(userInfo)
                                           withCompletionHandler:^{
                                               [exp fulfill];
                                           }];
                        [XCTWaiter waitForExpectations:@[exp] timeout:5];
                    });
                }

            });
        }

SPEC_END