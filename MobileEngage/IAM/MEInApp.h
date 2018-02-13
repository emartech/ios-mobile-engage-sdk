//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppMessageHandler.h"
#import "MEInAppTrackingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MEInApp : NSObject

@property(nonatomic, weak, nullable) id <MEInAppMessageHandler> messageHandler;

@end

NS_ASSUME_NONNULL_END