//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMRequestPushPermission.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "MEOsVersionUtils.h"

@implementation MEIAMRequestPushPermission

+ (NSString *)commandName {
    return @"requestPushPermission";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    UIApplication *application = [UIApplication sharedApplication];
    [application registerForRemoteNotifications];

    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        resultBlock(@{@"success": @([application isRegisteredForRemoteNotifications])});
    } else {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge
                                                                            completionHandler:^(BOOL granted, NSError *error) {
                                                                                resultBlock(@{@"success": @(granted)});
                                                                            }];
    }
}

@end