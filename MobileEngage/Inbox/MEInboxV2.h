//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotificationInboxStatus.h"
#import "MEInboxProtocol.h"
#import "MERequestContext.h"
#import "MEInboxNotificationProtocol.h"

@interface MEInboxV2 : NSObject <MEInboxNotificationProtocol>

- (instancetype)initWithConfig:(MEConfig *)config
                requestContext:(MERequestContext *)requestContext;

@end