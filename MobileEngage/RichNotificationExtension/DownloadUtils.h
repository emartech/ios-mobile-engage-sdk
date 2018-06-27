//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void(^DownloadTaskCompletionHandler)(NSURL *destinationUrl, NSError *error);

@interface DownloadUtils : NSObject

+ (void)downloadFileFromUrl:(NSURL *)sourceUrl
          completionHandler:(DownloadTaskCompletionHandler)completionHandler;

@end