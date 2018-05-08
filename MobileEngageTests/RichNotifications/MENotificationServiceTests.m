//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"

SPEC_BEGIN(MENotificationServiceTests)

        if (@available(iOS 10.0, *)) {
            describe(@"didReceiveNotificationRequest:withContentHandler:", ^{
                context(@"with image", ^{
                    it(@"should invoke contentHandler with nil when there contentInfo is not mutable", ^{
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

                    it(@"should invoke contentHandler with the original content when cant create attachment from the imageUrl in the request's userInfo", ^{
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

                    it(@"should be resilient if category is not expected type: NSDictionary", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"actions": @978};

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

                    it(@"should set category on content which is already registered on userNotificationCenter", ^{
                        MENotificationService *service = [[MENotificationService alloc] init];
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        content.userInfo = @{@"actions": @{
                            @"UUID1": @{
                                @"title": @"buttonTitle"
                            },
                            @"UUID2": @{
                                @"title": @"buttonTitle2"
                            }
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
                });
            });
        }

SPEC_END
