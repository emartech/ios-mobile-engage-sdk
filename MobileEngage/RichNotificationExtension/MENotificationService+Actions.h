//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

typedef void(^ActionsCompletionHandler)(UNNotificationCategory *category);

@interface MENotificationService (Actions)

- (void)createCategoryForContent:(UNMutableNotificationContent *)content
               completionHandler:(ActionsCompletionHandler)completionHandler;

@end

#pragma clang diagnostic pop
