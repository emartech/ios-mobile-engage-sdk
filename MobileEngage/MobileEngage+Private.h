//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileEngage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileEngage (Private)

+ (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage;

@end

NS_ASSUME_NONNULL_END