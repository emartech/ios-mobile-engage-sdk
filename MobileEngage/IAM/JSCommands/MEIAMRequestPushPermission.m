//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMRequestPushPermission.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "MEOsVersionUtils.h"
#import "MEIAMCommandResultUtils.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@implementation MEIAMRequestPushPermission

+ (NSString *)commandName {
    return @"requestPushPermission";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    UIApplication *application = [UIApplication sharedApplication];
    [application registerForRemoteNotifications];
    NSString *eventId = message[@"id"];

    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        resultBlock([self createResultWithJSCommandId:eventId
                                              success:[application isRegisteredForRemoteNotifications]]);
    } else {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge
                                                                            completionHandler:^(BOOL granted, NSError *error) {
                                                                                resultBlock([self createResultWithJSCommandId:eventId
                                                                                                                      success:granted]);
                                                                            }];
    }
}

- (NSDictionary<NSString *, NSObject *> *)createResultWithJSCommandId:(NSString *)jsCommandId
                                                              success:(BOOL)success {
    NSDictionary<NSString *, NSObject *> *result;
    if (success) {
        result = [MEIAMCommandResultUtils createSuccessResultWith:jsCommandId];
    } else {
        result = [MEIAMCommandResultUtils createErrorResultWith:jsCommandId
                                                    errorMessage:@"Registering for push notifications failed!"];
    }
    return result;
}

@end

#pragma clang diagnostic pop