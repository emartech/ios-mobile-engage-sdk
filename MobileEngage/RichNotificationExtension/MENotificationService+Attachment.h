//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"

typedef void(^AttachmentsCompletionHandler)(NSArray<UNNotificationAttachment *> *attachments);

@interface MENotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                 completionHandler:(AttachmentsCompletionHandler)completionHandler;

@end