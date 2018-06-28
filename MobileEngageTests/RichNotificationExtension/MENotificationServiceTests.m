//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"
#import "MENotificationService+Attachment.h"
#import "MENotificationService+Actions.h"
#import "KWNilMatcher.h"

SPEC_BEGIN(MENotificationServiceTests)

        if (@available(iOS 10.0, *)) {
            describe(@"didReceiveNotificationRequest:withContentHandler:", ^{


            });
        }

        describe(@"createAttachmentForContent:completionHandler:", ^{

            void (^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = ^(MENotificationService *service, UNMutableNotificationContent *content) {
                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      [exp fulfill];
                                  }];
                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];
            };

            it(@"should return with nil when content doesnt contain image url", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{};

                MENotificationService *service = [[MENotificationService alloc] init];

                __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      result = attachments;
                                      [exp fulfill];
                                  }];
                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[result should] beNil];
            });

            it(@"should not crash when content doesnt contain image url and completionHandler is nil", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{};

                MENotificationService *service = [[MENotificationService alloc] init];

                [service createAttachmentForContent:content
                                  completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with array of attachments when content contains image url", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"image_url": @"https://ems-denna.herokuapp.com/images/Emarsys.png"};

                MENotificationService *service = [[MENotificationService alloc] init];

                __block NSArray<UNNotificationAttachment *> *result = [NSArray array];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createAttachmentForContent:content
                                  completionHandler:^(NSArray<UNNotificationAttachment *> *attachments) {
                                      result = attachments;
                                      [exp fulfill];
                                  }];
                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];

                [[result shouldNot] beNil];
                [[[[result firstObject] identifier] should] equal:@"Emarsys.png"];
            });

            it(@"should not crash when content contains image url and completionHandler is nil", ^{
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"image_url": @"https://ems-denna.herokuapp.com/images/Emarsys.png"};

                MENotificationService *service = [[MENotificationService alloc] init];

                [service createAttachmentForContent:content
                                  completionHandler:nil];

                waitUntilNextResult(service, content);
            });
        });

        describe(@"createCategoryForContent:completionHandler:", ^{

            UNNotificationCategory *(^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = (UNNotificationCategory *(^)(MENotificationService *, UNMutableNotificationContent *)) (UNNotificationCategory *) ^(MENotificationService *service, UNMutableNotificationContent *content) {
                __block UNNotificationCategory *result = [UNNotificationCategory new];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
                [service createCategoryForContent:content
                                completionHandler:^(UNNotificationCategory *category) {
                                    result = category;
                                    [exp fulfill];
                                }];
                [XCTWaiter waitForExpectations:@[exp]
                                       timeout:30];

                return result;
            };

            it(@"should return with nil when there is no actions in the content", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash when there is no actions in the content and completionHandler is nil", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{}};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with category that contains MEAppEvent, when the content contains MEAppEvent action", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID1",
                            @"title": @"buttonTitle",
                            @"type": @"MEAppEvent",
                            @"name": @"nameOfTheEvent"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID1"];
                [[[action title] should] equal:@"buttonTitle"];
            });

            it(@"should not crash when category that contains MEAppEvent, when the content contains MEAppEvent action but completionHandler is nil", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID1",
                            @"title": @"buttonTitle",
                            @"type": @"MEAppEvent",
                            @"name": @"nameOfTheEvent"
                        }
                    ]
                }};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with nil when the content contains MEAppEvent action type but there are missing parameters", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID1",
                            @"title": @"buttonTitle",
                            @"type": @"MEAppEvent"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should not crash when when the content contains MEAppEvent action type but there are missing parameters and completionHandler is nil", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID1",
                            @"title": @"buttonTitle",
                            @"type": @"MEAppEvent"
                        }
                    ]
                }};

                [service createCategoryForContent:content
                                completionHandler:nil];

                waitUntilNextResult(service, content);
            });

            it(@"should return with category that contains OpenExternalUrl, when the content contains OpenExternalUrl action", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID2",
                            @"title": @"buttonTitleForOpenUrl",
                            @"type": @"OpenExternalUrl",
                            @"url": @"https://www.emarsys.com"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID2"];
                [[[action title] should] equal:@"buttonTitleForOpenUrl"];
            });

            it(@"should return with nil when the content contains OpenExternalUrl action type but there are missing parameters", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID2",
                            @"title": @"buttonTitleForOpenUrl",
                            @"type": @"OpenExternalUrl"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });

            it(@"should return with category that contains MECustomEvent, when the content contains MECustomEvent action", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID3",
                            @"title": @"buttonTitleForCustomEvent",
                            @"type": @"MECustomEvent",
                            @"name": @"CustomEventName"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                UNNotificationAction *action = [[result actions] firstObject];
                [[[action identifier] should] equal:@"UUID3"];
                [[[action title] should] equal:@"buttonTitleForCustomEvent"];
            });

            it(@"should return with nil when the content contains OpenExternalUrl action type but there are missing parameters", ^{
                MENotificationService *service = [[MENotificationService alloc] init];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.userInfo = @{@"ems": @{
                    @"actions": @[
                        @{
                            @"id": @"UUID3",
                            @"title": @"buttonTitleForCustomEvent",
                            @"type": @"MECustomEvent"
                        }
                    ]
                }};

                UNNotificationCategory *result = waitUntilNextResult(service, content);

                [[result should] beNil];
            });
        });

SPEC_END
