//
//  Copyright © 2017. Emarsys. All rights reserved.
//

#import <CoreSDK/EMSDictionaryValidator.h>
#import "MENotificationService.h"
#import "UNNotificationAttachment+MobileEngage.h"

#define IMAGE_URL @"image_url"

@interface MENotificationService ()

@property(nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property(nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation MENotificationService

#pragma mark - UNNotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [self mutableCopyOfContent:request];

    UNMutableNotificationContent *content = [self mutableCopyOfContent:request];
    if (!content) {
        contentHandler(request.content);
        return;
    }

    NSArray *validatorErrors = [content.userInfo validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"actions"
                           withType:[NSDictionary class]];
    }];
    if ([validatorErrors count] == 0) {
        NSMutableArray *actions = [NSMutableArray array];

        [content.userInfo[@"actions"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *value, BOOL *stop) {
            [actions addObject:[UNNotificationAction actionWithIdentifier:key
                                                                    title:value[@"title"]
                                                                  options:UNNotificationActionOptionNone]];
        }];

        NSString *const categoryIdentifier = [NSUUID UUID].UUIDString;
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryIdentifier
                                                                                  actions:actions
                                                                        intentIdentifiers:@[]
                                                                                  options:0];
        content.categoryIdentifier = categoryIdentifier;

        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[category]]];
    }

    NSArray<UNNotificationAttachment *> *attachments = [self attachmentsForContent:request.content];
    if (attachments) {
        content.attachments = attachments;
    }

    contentHandler(content.copy);
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

- (UNMutableNotificationContent *)mutableCopyOfContent:(UNNotificationRequest *)request {
    return (UNMutableNotificationContent *) [request.content mutableCopy];
}

- (NSArray<UNNotificationAttachment *> *)attachmentsForContent:(UNNotificationContent *)content {
    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    NSArray<UNNotificationAttachment *> *attachments;
    if (mediaUrl) {
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithMediaUrl:mediaUrl
                                                                                        options:nil];
        if (attachment) {
            attachments = @[attachment];
        }
    }
    return attachments;
}

@end
