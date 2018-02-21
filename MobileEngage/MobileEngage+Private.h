//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

#import "MobileEngage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileEngage (Private)

+ (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage;
+ (EMSSQLiteHelper *)dbHelper;
+ (void)setDbHelper:(EMSSQLiteHelper *)dbHelper;

@end

NS_ASSUME_NONNULL_END
