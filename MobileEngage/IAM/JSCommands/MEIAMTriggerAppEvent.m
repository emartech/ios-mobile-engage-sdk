//
//  MEIAMTriggerAppEvent.m
//  MobileEngage
//
//  Created by Laszlo Ori on 2017. 12. 06..
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "MEIAMTriggerAppEvent.h"

@implementation MEIAMTriggerAppEvent

+ (NSString *)commandName {
    return @"triggerAppEvent";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *name = message[@"name"];
    NSDictionary *payload = message[@"payload"];
}

@end
