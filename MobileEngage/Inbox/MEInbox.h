//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileEngageSDK/MENotificationInboxStatus.h>
#import <MobileEngageSDK/MEInboxProtocol.h>
#import <MobileEngageSDK/MEInboxNotificationProtocol.h>

@class MERequestContext;

@interface MEInbox : NSObject <MEInboxNotificationProtocol>

- (instancetype)initWithConfig:(MEConfig *)config
                requestContext:(MERequestContext *)requestContext;

@end
