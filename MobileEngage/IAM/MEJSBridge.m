//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEJSBridge.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@implementation MEJSBridge

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (void)requestPushPermission {
    UIApplication *application = [UIApplication sharedApplication];
    [application registerForRemoteNotifications];

    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge
                                                                            completionHandler:nil];
    }
}

- (void)openExternalLink:(NSString *)link
       completionHandler:(void (^)(BOOL))completionHandler {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:link];
    if ([application canOpenURL:url]) {
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            completionHandler([application openURL:url]);
        } else {
            [application openURL:url options:nil completionHandler:^(BOOL success) {
                completionHandler(success);
            }];
        }
    } else {
        completionHandler(false);
    }
}

@end