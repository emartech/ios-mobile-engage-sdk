//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEJSBridge : NSObject

- (void)requestPushPermission;

- (void)openExternalLink:(NSString *)link
       completionHandler:(void (^)(BOOL success))completionHandler;
@end