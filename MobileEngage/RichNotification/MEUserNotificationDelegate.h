//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MEUserNotificationCenterDelegate.h"
#import "MEIAMProtocol.h"

@class MobileEngageInternal;

NS_ASSUME_NONNULL_BEGIN

@interface MEUserNotificationDelegate: NSObject <MEUserNotificationCenterDelegate>

- (instancetype)initWithApplication:(UIApplication *)application
               mobileEngageInternal:(MobileEngageInternal *)mobileEngage
                              inApp:(id <MEIAMProtocol>)inApp;

@end

NS_ASSUME_NONNULL_END