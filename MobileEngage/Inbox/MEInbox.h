//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotification.h"
#import "EMSRESTClient.h"
#import "MENotificationInboxStatus.h"

@class MEConfig;
@class MEAppLoginParameters;

typedef void (^MEInboxSuccessBlock)();
typedef void (^MEInboxResultBlock)(MENotificationInboxStatus *inboxStatus);
typedef void (^MEInboxResultErrorBlock)(NSError *error);

@interface MEInbox : NSObject

@property(nonatomic, strong) MEAppLoginParameters *appLoginParameters;

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock;

- (void)resetBadgeCount;

@end