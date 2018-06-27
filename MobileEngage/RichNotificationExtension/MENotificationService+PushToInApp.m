//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MENotificationService.h"
#import <CoreSDK/EMSDictionaryValidator.h>
#import "MENotificationService+PushToInApp.h"
#import "DownloadUtils.h"

@implementation MENotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                        completionHandler:(PushToInAppCompletionHandler)completionHandler {
    NSDictionary *pushToInAppDict = [self extractPushToInAppFromContent:content];
    if (pushToInAppDict) {
        [DownloadUtils downloadFileFromUrl:[NSURL URLWithString:pushToInAppDict[@"url"]]
                completionHandler:^(NSURL *destinationUrl, NSError *error) {
                    NSError *dataCreatingError;
                    NSData *pushToInAppData = [NSData dataWithContentsOfURL:destinationUrl
                                                                    options:NSDataReadingMappedIfSafe
                                                                      error:&dataCreatingError];
                    NSMutableDictionary *contentDict = [content.userInfo mutableCopy];
                    contentDict[@"ems"][@"inapp"][@"inAppData"] = pushToInAppData;
                    completionHandler([NSDictionary dictionaryWithDictionary:contentDict]);
                }];
    } else {
        completionHandler(nil);
    }
}

- (NSDictionary *)extractPushToInAppFromContent:(UNMutableNotificationContent *)content {
    NSDictionary *result;
    NSArray *emsErrors = [content.userInfo validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"ems"
                           withType:[NSDictionary class]];
    }];
    if ([emsErrors count] == 0) {
        NSDictionary *ems = content.userInfo[@"ems"];
        NSArray *pushToInAppErrors = [ems validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"inapp"
                               withType:[NSDictionary class]];
        }];
        if ([pushToInAppErrors count] == 0) {
            NSDictionary *inApp = ems[@"inapp"];
            NSArray *inAppErrors = [inApp validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"campaignId"
                                   withType:[NSString class]];
                [validate valueExistsForKey:@"url"
                                   withType:[NSString class]];
            }];
            if ([inAppErrors count] == 0) {
                result = inApp;
            }
        }
    }
    return result;
}
@end