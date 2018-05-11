//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import "MEEventHandler.h"

@interface MEUserNotification: NSObject <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate;
@property(nonatomic, weak) id <MEEventHandler> eventHandler;

@end