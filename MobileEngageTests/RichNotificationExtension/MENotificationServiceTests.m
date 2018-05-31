//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"

SPEC_BEGIN(MENotificationServiceTests)

        if (@available(iOS 10.0, *)) {
            describe(@"didReceiveNotificationRequest:withContentHandler:", ^{
                context(@"with image", ^{
                    it(@"should invoke contentHandler with nil when the contentInfo is not mutable", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNNotificationContent *content = [UNNotificationContent mock];
                        [content stub:@selector(mutableCopy) andReturn:nil];
                        [content stub:@selector(copyWithZone:) andReturn:nil];

                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"id"
                                                                                              content:content
                                                                                              trigger:nil];
                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];

                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent should] beNil];
                    });

                    it(@"should invoke contentHandler with the original content when there is no imageUrl in the request's userInfo", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{};
                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"id"
                                                                                              content:content
                                                                                              trigger:nil];
                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];

                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent should] equal:content];
                    });

                    it(@"should invoke contentHandler with the original content when can't create attachment from the imageUrl in the request's userInfo", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"image_url": @""};
                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"id"
                                                                                              content:content
                                                                                              trigger:nil];
                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];

                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent should] equal:content];
                    });

                    it(@"should invoke contentHandler with modified content when attachment is available", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"image_url": @"https://cinesnark.files.wordpress.com/2015/05/widow_mace.gif"};
                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"id"
                                                                                              content:content
                                                                                              trigger:nil];
                        XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];

                        __block UNNotificationContent *returnedContent;
                        [service didReceiveNotificationRequest:request
                                            withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                returnedContent = contentToDeliver;
                                                [exp fulfill];

                                            }];

                        [XCTWaiter waitForExpectations:@[exp]
                                               timeout:30];

                        [[returnedContent.attachments shouldNot] beNil];
                        [[returnedContent.attachments[0] should] beKindOfClass:[UNNotificationAttachment class]];
                    });
                });

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

SPEC_END
