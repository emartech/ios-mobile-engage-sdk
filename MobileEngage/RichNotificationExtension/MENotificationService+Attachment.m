//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MENotificationService.h"
#import "MENotificationService+Attachment.h"
#import "MEDownloadUtils.h"

#define IMAGE_URL @"image_url"

@implementation MENotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                 completionHandler:(AttachmentsCompletionHandler)completionHandler {
    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    [MEDownloadUtils downloadFileFromUrl:mediaUrl
            completionHandler:^(NSURL *destinationUrl, NSError *error) {
                if (!error) {
                    NSError *attachmentCreationError;
                    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:destinationUrl.lastPathComponent
                                                                                                          URL:destinationUrl
                                                                                                      options:nil
                                                                                                        error:&attachmentCreationError];
                    if (attachment && !attachmentCreationError) {
                        completionHandler(@[attachment]);
                    } else {
                        completionHandler(nil);
                    }
                } else {
                    completionHandler(nil);
                }
            }];
}
@end