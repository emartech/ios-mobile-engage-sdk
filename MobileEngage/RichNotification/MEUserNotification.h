//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MEUserNotificationCenterDelegate.h"

@interface MEUserNotification: NSObject <MEUserNotificationCenterDelegate>

- (instancetype)initWithApplication:(UIApplication *)application;

@end
