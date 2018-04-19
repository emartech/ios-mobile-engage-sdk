//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotificationInboxStatus.h"
#import "MEInboxProtocol.h"

@class MEConfig;
@class MEAppLoginParameters;

@interface MEInbox : NSObject <MEInboxProtocol>

@property(nonatomic, strong) MEAppLoginParameters *appLoginParameters;

@end
