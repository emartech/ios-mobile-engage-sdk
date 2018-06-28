//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEDownloadUtils.h"
#import <CoreSDK/NSError+EMSCore.h>


@implementation MEDownloadUtils

+ (void)downloadFileFromUrl:(NSURL *)sourceUrl
          completionHandler:(DownloadTaskCompletionHandler)completionHandler {
    if (sourceUrl) {
        NSURLSessionDownloadTask *task = [[self urlSession] downloadTaskWithURL:sourceUrl
                                                              completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                  NSURL *mediaFileUrl = [self createLocalTempUrlFromRemoteUrl:sourceUrl];
                                                                  if (!error) {
                                                                      if (location && mediaFileUrl) {
                                                                          NSError *moveError;
                                                                          BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                                                     toURL:mediaFileUrl
                                                                                                                                     error:&moveError];
                                                                          if (moveSuccess && !moveError) {
                                                                              if (completionHandler) {
                                                                                  completionHandler(mediaFileUrl, nil);
                                                                              }
                                                                          } else {
                                                                              if (completionHandler) {
                                                                                  completionHandler(nil, moveError);
                                                                              }
                                                                          }
                                                                      } else {
                                                                          if (completionHandler) {
                                                                              completionHandler(nil, [NSError errorWithCode:1415
                                                                                                       localizedDescription:@"Unsupported file url."]);
                                                                          }
                                                                      }
                                                                  } else {
                                                                      if (completionHandler) {
                                                                          completionHandler(nil, error);
                                                                      }
                                                                  }
                                                              }];
        [task resume];
    } else {
        if (completionHandler) {
            completionHandler(nil, [NSError errorWithCode:1400
                                     localizedDescription:@"Source url doesn't exist."]);
        }
    }
}

+ (NSURLSession *)urlSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setTimeoutIntervalForRequest:30.0];
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                delegate:nil
                                           delegateQueue:operationQueue];
    });
    return session;
}

+ (NSURL *)createLocalTempUrlFromRemoteUrl:(NSURL *)remoteUrl {
    NSURL *mediaFileUrl;
    NSString *mediaFileName = remoteUrl.pathComponents.lastObject;
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