//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENotificationInboxStatus.h"
#import "MEInboxProtocol.h"



@interface MEInboxV2 : NSObject <MEInboxProtocol>

@property (nonatomic, strong) NSString *meId;

@end