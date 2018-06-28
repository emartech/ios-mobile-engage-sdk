//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"
#import "MENotificationService+Attachment.h"

SPEC_BEGIN(MENotificationServiceTests)

        if (@available(iOS 10.0, *)) {
            describe(@"didReceiveNotificationRequest:withContentHandler:", ^{

                context(@"with actions", ^{

                    it(@"should not set category when ems is not the expected type: NSDictionary", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @978};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier should] equal:@""];
                    });

                    it(@"should not set category when actions is not the expected type: NSArray", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{@"actions": @978}};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier should] equal:@""];
                    });

                    it(@"should use a registered category on content with actions defined in the userinfo", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID1",
                                    @"title": @"buttonTitle",
                                    @"type": @"MEAppEvent",
                                    @"name": @"nameOfTheEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(2)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle"];
                        [[returnedCategory.actions[1].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should use pre registered category and also registered category on content with actions defined in the userinfo", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID1",
                                    @"title": @"buttonTitle",
                                    @"type": @"MEAppEvent",
                                    @"name": @"nameOfTheEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};
                        UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"id"
                                                                                            title:@"title"
                                                                                          options:UNNotificationActionOptionNone];

                        UNNotificationCategory *expectedCategory = [UNNotificationCategory categoryWithIdentifier:@"categoryIdentifier"
                                                                                                          actions:@[action]
                                                                                                intentIdentifiers:@[]
                                                                                                          options:0];
                        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[expectedCategory]]];

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block NSSet<UNNotificationCategory *> *returnedCategories;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            returnedCategories = categories;
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategories count]) should] equal:theValue(2)];
                        [[returnedCategories should] contain:expectedCategory];
                    });

                    it(@"should not create the action when id is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"title": @"buttonTitle",
                                    @"type": @"MEAppEvent",
                                    @"name": @"nameOfTheEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when title is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"type": @"MEAppEvent",
                                    @"name": @"nameOfTheEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when type is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"title": @"buttonTitle",
                                    @"name": @"nameOfTheEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when type is MEAppEvent and name is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"title": @"buttonTitle",
                                    @"type": @"MEAppEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"MEAppEvent",
                                    @"name": @"nameOfTheEvent"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when type is OpenExternalUrl and url is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"title": @"buttonTitle",
                                    @"type": @"OpenExternalUrl"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when type is OpenExternalUrl and url is invalid", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"title": @"buttonTitle",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"invalid url"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"OpenExternalUrl",
                                    @"url": @"https://www.emarsys.com"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });

                    it(@"should not create the action when type is MECustomEvent and name is missing", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"ems": @{
                            @"actions": @[
                                @{
                                    @"id": @"UUID",
                                    @"title": @"buttonTitle",
                                    @"type": @"MECustomEvent"
                                },
                                @{
                                    @"id": @"UUID2",
                                    @"title": @"buttonTitle2",
                                    @"type": @"MECustomEvent",
                                    @"name": @"nameOfTheEvent"
                                }
                            ]
                        }};

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                                              content:content
                                                                                              trigger:nil];

                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForNotificationContent"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];
                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.categoryIdentifier shouldNot] beNil];

                        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCategories"];

                        __block UNNotificationCategory *returnedCategory;
                        [UNUserNotificationCenter.currentNotificationCenter getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
                            for (UNNotificationCategory *category in categories) {
                                if ([category.identifier isEqualToString:returnedContent.categoryIdentifier]) {
                                    returnedCategory = category;
                                    break;
                                }
                            }
                            [expectation fulfill];
                        }];

                        [XCTWaiter waitForExpectations:@[expectation]
                                               timeout:30];

                        [[theValue([returnedCategory.actions count]) should] equal:theValue(1)];
                        [[returnedCategory.actions[0].title should] equal:@"buttonTitle2"];
                    });
                });
            });
        }

        describe(@"createAttachmentForContent:completionHandler:", ^{

            void (^waitUntilNextResult)(MENotificationService *service, UNMutableNotificationContent *content) = ^(MENotificationService *service, UNMutableNotificationContent *content){
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

SPEC_END
