//
//  Copyright © 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@protocol MEInAppMessageHandler;

@interface MEIAMTriggerAppEvent : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithInAppMessageHandler:(id<MEInAppMessageHandler>)inAppMessageHandler;

@end
