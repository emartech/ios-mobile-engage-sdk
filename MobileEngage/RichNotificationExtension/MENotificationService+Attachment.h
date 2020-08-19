//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"
#import "MEDownloader.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

typedef void(^AttachmentsCompletionHandler)(NSArray<UNNotificationAttachment *> *attachments);

@interface MENotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                    withDownloader:(MEDownloader *)downloader
                 completionHandler:(AttachmentsCompletionHandler)completionHandler;

@end

#pragma clang diagnostic pop
