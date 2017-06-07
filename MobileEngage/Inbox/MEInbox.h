//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotification.h"

typedef void (^MEInboxResultBlock)(NSArray<MENotification *> *notifications);

@interface MEInbox : NSObject

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock;

@end