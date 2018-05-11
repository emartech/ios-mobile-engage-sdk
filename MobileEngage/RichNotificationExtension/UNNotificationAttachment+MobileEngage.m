//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "UNNotificationAttachment+MobileEngage.h"

@implementation UNNotificationAttachment (MobileEngage)

+ (instancetype)attachmentWithMediaUrl:(NSURL *)mediaUrl
                               options:(NSDictionary *)options {

    NSURL *mediaFileUrl = [self prepareMediaFromURL:mediaUrl];
    return [UNNotificationAttachment attachmentWithIdentifier:mediaFileUrl.lastPathComponent
                                                          URL:mediaFileUrl
                                                      options:options
                                                        error:nil];
}

+ (NSURL *)prepareMediaFromURL:(NSURL *)mediaURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *mediaFileName = mediaURL.lastPathComponent;
    NSString *tmpSubFolderName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *tmpSubFolderUrl = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:tmpSubFolderName
                                                                                             isDirectory:YES];
    NSData *mediaData = [NSData dataWithContentsOfURL:mediaURL];
    if (mediaData) {
        [fileManager createDirectoryAtURL:tmpSubFolderUrl
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:nil];

        NSURL *mediaFileUrl = [tmpSubFolderUrl URLByAppendingPathComponent:mediaFileName];
        [mediaData writeToURL:mediaFileUrl
                      options:NSDataWritingAtomic
                        error:nil];
        return mediaFileUrl;
    }

    return nil;
}

@end