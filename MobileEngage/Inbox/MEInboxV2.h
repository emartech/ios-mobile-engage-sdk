//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSRESTClient.h>
#import <Foundation/Foundation.h>
#import "MEInboxProtocol.h"
#import "MEInboxNotificationProtocol.h"
#import "MERequestContext.h"

@interface MEInboxV2 : NSObject <MEInboxNotificationProtocol>

- (instancetype)initWithConfig:(MEConfig *)config
                requestContext:(MERequestContext *)requestContext
                    restClient:(EMSRESTClient *)restClient
                 notifications:(NSMutableArray *)notifications;

@end