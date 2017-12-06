//
//  MEIAMTriggerAppEvent.m
//  MobileEngage
//
//  Created by Laszlo Ori on 2017. 12. 06..
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "MEIAMTriggerAppEvent.h"
#import "MEInAppMessageHandler.h"

@interface MEIAMTriggerAppEvent()

@property(nonatomic, weak, nullable) id <MEInAppMessageHandler> inAppMessageHandler;

@end

@implementation MEIAMTriggerAppEvent

- (instancetype)initWithInAppMessageHandler:(id <MEInAppMessageHandler>)inAppMessageHandler {
    if (self = [super init]) {
        _inAppMessageHandler = inAppMessageHandler;
    }
    return self;
}


+ (NSString *)commandName {
    return @"triggerAppEvent";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *name = message[@"name"];
    NSDictionary *payload = message[@"payload"];
    [self.inAppMessageHandler handleApplicationEvent:name
                                             payload:payload];
    resultBlock(@{@"success": @YES});
}

@end
