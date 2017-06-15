#import "Kiwi.h"
#import "MEInboxParser.h"
#import "MENotification.h"
#import "MENotificationInboxStatus.h"

SPEC_BEGIN(InboxParserTests)

    describe(@"InboxParser.parseNotificationInboxStatus:", ^{
        it(@"should not return nil", ^{
            MEInboxParser *parser = [MEInboxParser new];
            MENotificationInboxStatus *result = [parser parseNotificationInboxStatus:@{}];
            [[theValue(result) shouldNot] beNil];
        });

        it(@"should return with correct notificationStatus", ^{
            MEInboxParser *parser = [MEInboxParser new];
            NSDictionary *notificationInboxStatus = @{
                    @"notifications": @[
                            @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)},
                            @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)}
                    ],
                    @"badge_count": @3
            };
            NSMutableArray<MENotification *> *expectedNotifications = [NSMutableArray array];
            for (NSDictionary *notificationDict in notificationInboxStatus[@"notifications"]) {
                [expectedNotifications addObject:[[MENotification alloc] initWithNotificationDictionary:notificationDict]];
            }
            MENotificationInboxStatus *result = [parser parseNotificationInboxStatus:notificationInboxStatus];

            [[result.notifications should] equal:expectedNotifications];
            [[theValue(result.badgeCount) should] equal:theValue(3)];
        });
    });

    describe(@"InboxParser.parseArrayOfNotifications:", ^{
        it(@"should not return nil", ^{
            MEInboxParser *parser = [MEInboxParser new];
            NSArray<MENotification *> *result = [parser parseArrayOfNotifications:@[]];
            [[theValue(result) shouldNot] beNil];
        });

        it(@"should create the correct array", ^{
            MEInboxParser *parser = [MEInboxParser new];
            NSDictionary *notificationInboxStatus = @{
                    @"notifications": @[
                            @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)},
                            @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)}
                    ],
                    @"badge_count": @3
            };
            NSMutableArray<MENotification *> *expectedNotifications = [NSMutableArray array];
            for (NSDictionary *notificationDict in notificationInboxStatus[@"notifications"]) {
                [expectedNotifications addObject:[[MENotification alloc] initWithNotificationDictionary:notificationDict]];
            }
            NSArray<MENotification *> *result = [parser parseArrayOfNotifications:notificationInboxStatus[@"notifications"]];

            [[result should] equal:expectedNotifications];
        });
    });

    describe(@"InboxParser.parseNotification:", ^{
        it(@"should not return nil", ^{
            MEInboxParser *parser = [MEInboxParser new];
            MENotification *result = [parser parseNotification:@{}];
            [[theValue(result) shouldNot] beNil];
        });

        it(@"should create the correct notification", ^{
            MEInboxParser *parser = [MEInboxParser new];
            NSDictionary *notificationDict = @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678.123)};
            MENotification *result = [parser parseNotification:notificationDict];
            [[result should] equal:[[MENotification alloc] initWithNotificationDictionary:notificationDict]];
        });
    });

SPEC_END