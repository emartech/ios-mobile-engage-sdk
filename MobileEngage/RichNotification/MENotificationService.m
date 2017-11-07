//
//  Copyright © 2017. Emarsys. All rights reserved.
//

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
    self.bestAttemptContent = (UNMutableNotificationContent *) [request.content mutableCopy];

    UNMutableNotificationContent *content = (UNMutableNotificationContent *) [request.content mutableCopy];
    if (!content) {
        contentHandler(request.content);
        return;
    }

    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    if (!mediaUrl) {
        contentHandler(request.content);
        return;
    }

    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithMediaUrl:mediaUrl
                                                                                    options:nil];
    if (!attachment) {
        contentHandler(request.content);
        return;
    }

    content.attachments = @[attachment];
    contentHandler(content.copy);
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

@end
