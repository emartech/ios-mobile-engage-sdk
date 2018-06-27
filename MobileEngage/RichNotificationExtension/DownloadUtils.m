//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "DownloadUtils.h"
#import <CoreSDK/NSError+EMSCore.h>


@implementation DownloadUtils

+ (void)downloadFileFromUrl:(NSURL *)sourceUrl
          completionHandler:(DownloadTaskCompletionHandler)completionHandler {
    if (sourceUrl) {
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:sourceUrl
                                                                         completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                             NSURL *mediaFileUrl = [self createLocalTempUrlFromRemoteUrl:sourceUrl];
                                                                             if (!error) {
                                                                                 if (location && mediaFileUrl) {
                                                                                     NSError *moveError;
                                                                                     BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                                                                toURL:mediaFileUrl
                                                                                                                                                error:&moveError];
                                                                                     if (moveSuccess && !moveError) {
                                                                                         completionHandler(mediaFileUrl, nil);
                                                                                     } else {
                                                                                         completionHandler(nil, moveError);
                                                                                     }
                                                                                 } else {
                                                                                     completionHandler(nil, [NSError errorWithCode:1415
                                                                                                              localizedDescription:@"Unsupported media url."]);
                                                                                 }
                                                                             } else {
                                                                                 completionHandler(nil, error);
                                                                             }
                                                                         }];
        [task resume];
    } else {
        completionHandler(nil, [NSError errorWithCode:1400
                                 localizedDescription:@"SourceUrl doesn't exist."]);
    }
}

+ (NSURL *)createLocalTempUrlFromRemoteUrl:(NSURL *)remoteUrl {
    NSURL *mediaFileUrl;
    NSString *mediaFileName = remoteUrl.lastPathComponent;
    NSString *tmpSubFolderName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *tmpSubFolderUrl = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:tmpSubFolderName];
    NSError *directoryCreationError;
    [[NSFileManager defaultManager] createDirectoryAtURL:tmpSubFolderUrl
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&directoryCreationError];
    if (!directoryCreationError && tmpSubFolderName && mediaFileName) {
        mediaFileUrl = [tmpSubFolderUrl URLByAppendingPathComponent:mediaFileName];
    }
    return mediaFileUrl;
}

@end