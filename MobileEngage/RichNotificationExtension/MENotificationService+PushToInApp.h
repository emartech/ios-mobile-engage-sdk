//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"

typedef void(^PushToInAppCompletionHandler)(NSDictionary *userInfo);

@interface MENotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                        completionHandler:(PushToInAppCompletionHandler)completionHandler;

@end