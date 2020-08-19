//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"
#import "MEDownloader.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

typedef void(^PushToInAppCompletionHandler)(NSDictionary *userInfo);

@interface MENotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                           withDownloader:(MEDownloader *)downloader
                        completionHandler:(PushToInAppCompletionHandler)completionHandler;

@end

#pragma clang diagnostic pop