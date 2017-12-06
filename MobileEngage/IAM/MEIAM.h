//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface MEIAM : NSObject

@property(nonatomic, weak, nullable) id <MEInAppMessageHandler> inAppMessageHandler;

//TODO: implement
- (void)pause;

- (void)resume;

@end

NS_ASSUME_NONNULL_END