//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UserNotifications/UNUserNotificationCenter.h>
#import <MobileEngageSDK/MEEventHandler.h>

@protocol MEUserNotificationCenterDelegate <UNUserNotificationCenterDelegate>

@property(nonatomic, weak) id <UNUserNotificationCenterDelegate> delegate;
@property(nonatomic, weak) id <MEEventHandler> eventHandler;

@end
