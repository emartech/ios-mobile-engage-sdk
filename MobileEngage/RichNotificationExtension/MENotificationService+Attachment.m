//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MENotificationService.h"
#import "MENotificationService+Attachment.h"
#import "MEDownloader.h"

#define IMAGE_URL @"image_url"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@implementation MENotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                    withDownloader:(MEDownloader *)downloader
                 completionHandler:(AttachmentsCompletionHandler)completionHandler {
    NSParameterAssert(downloader);
    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    [downloader downloadFileFromUrl:mediaUrl
                  completionHandler:^(NSURL *destinationUrl, NSError *error) {
                      if (!error) {
                          NSError *attachmentCreationError;
                          UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:destinationUrl.lastPathComponent
                                                                                                                URL:destinationUrl
                                                                                                            options:nil
                                                                                                              error:&attachmentCreationError];
                          if (attachment && !attachmentCreationError) {
                              if (completionHandler) {
                                  completionHandler(@[attachment]);
                                  return;
                              }
                          }
                      }

                      if (completionHandler) {
                          completionHandler(nil);
                      }
                  }];
}
@end

#pragma clang diagnostic pop