//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface UNNotificationAttachment (MobileEngage)

+ (instancetype)attachmentWithMediaUrl:(NSURL *)mediaUrl
                               options:(NSDictionary *)options;

@end