//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEUserNotification.h"
#import <UserNotifications/UNNotificationResponse.h>
#import <UserNotifications/UNNotification.h>
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationRequest.h>

@interface MEUserNotification ()
@end

@implementation MEUserNotification

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
                      willPresentNotification:notification
                        withCompletionHandler:completionHandler];
    }
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if (self.delegate) {
        [self.delegate userNotificationCenter:center
               didReceiveNotificationResponse:response
                        withCompletionHandler:completionHandler];
    }

    NSDictionary *action = response.notification.request.content.userInfo[@"actions"][response.actionIdentifier];
    if ([action[@"type"] isEqualToString:@"MEAppEvent"]) {
        [self.eventHandler handleEvent:action[@"name"] payload:action[@"payload"]];
    }

    completionHandler();
}


@end