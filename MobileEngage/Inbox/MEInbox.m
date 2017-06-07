//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEInbox.h"

@implementation MEInbox


- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock {
    MENotification *notification = [MENotification new];
    notification.id = @"ID";
    notification.title = @"TITLE";
    notification.customData = @{
            @"key1": @"value1"
    };
    notification.rootParams = @{
            @"key2": @"value2"
    };
    notification.receivedAt = [NSDate dateWithTimeIntervalSince1970:123456789];
    notification.expirationTime = @42;

    dispatch_async(dispatch_get_main_queue(), ^{
        resultBlock(@[notification, [MENotification new], [MENotification new]]);
    });
}

@end