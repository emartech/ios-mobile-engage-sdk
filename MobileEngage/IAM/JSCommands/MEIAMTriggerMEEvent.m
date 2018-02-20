//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEIAMTriggerMEEvent.h"
#import "MEIAMCommamndResultUtils.h"
#import "MobileEngage.h"

@implementation MEIAMTriggerMEEvent

+ (NSString *)commandName {
    return @"triggerMEEvent";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *eventId = message[@"id"];
    NSString *name = message[@"name"];
    NSDictionary *payload = message[@"payload"];
    if (name) {
        resultBlock(@{
                @"success": @YES,
                @"id": eventId,
                @"meEventId": [MobileEngage trackCustomEvent:name
                                             eventAttributes:payload]
        });
    } else {
        resultBlock([MEIAMCommamndResultUtils createMissingParameterErrorResultWith:eventId
                                                                   missingParameter:@"name"]);
    }
}

@end