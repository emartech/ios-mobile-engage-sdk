#import "Kiwi.h"
#import "MobileEngage.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(InboxTests)

    describe(@"inbox.fetchNotificationsWithResultBlock", ^{
        it(@"should return not nil notifications", ^{

            __block NSArray *notifs;
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(NSArray<MENotification *> *notifications) {
                notifs = notifications;
            }];

            [[notifs shouldNotEventually] beNil];
        });

        it(@"should return at least one notification", ^{
            NSDictionary<NSString *, NSString *> *customData = @{
                    @"key1": @"value1"
            };
            NSDictionary<NSString *, NSString *> *rootParams = @{
                    @"key2": @"value2"
            };
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:123456789];

            __block NSArray *notifs;
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(NSArray<MENotification *> *notifications) {
                notifs = notifications;
            }];

            [[notifs shouldNotEventually] beNil];
            [[notifs[2] shouldNotEventually] beNil];
            [[[notifs[0] id] shouldEventually] equal:@"ID"];
            [[[notifs[0] title] shouldEventually] equal:@"TITLE"];
            [[[notifs[0] customData] shouldEventually] equal:customData];
            [[[notifs[0] rootParams] shouldEventually] equal:rootParams];
            [[[notifs[0] expirationTime] shouldEventually] equal:@42];
            [[[notifs[0] receivedAt] shouldEventually] equal:date];
        });

        it(@"should block asyncronously", ^{
            __block BOOL ranAsync = YES;
            [MobileEngage.inbox fetchNotificationsWithResultBlock:^(NSArray<MENotification *> *notifications) {
                ranAsync = NO;
            }];
            [[theValue(ranAsync) should] beYes];
        });

    });

SPEC_END