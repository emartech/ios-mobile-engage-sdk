//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileEngageSDK/MEInboxProtocol.h>

@protocol MEInboxNotificationProtocol <MEInboxProtocol>

- (void)addNotification:(MENotification *)notification;

@end
