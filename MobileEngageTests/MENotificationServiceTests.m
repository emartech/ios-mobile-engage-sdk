//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MENotificationService.h"

SPEC_BEGIN(MENotificationServiceTests)

    describe(@"didReceiveNotificationRequest:withContentHandler:", ^{
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
            content.userInfo = @{@"imageUrl": @""};
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
            content.userInfo = @{@"imageUrl": @"https://cinesnark.files.wordpress.com/2015/05/widow_mace.gif"};
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

SPEC_END
