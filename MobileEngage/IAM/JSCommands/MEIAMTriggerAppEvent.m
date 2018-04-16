//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSDictionaryValidator.h>
#import "MEIAMTriggerAppEvent.h"
#import "MEInAppMessageHandler.h"
#import "MEIAMCommandResultUtils.h"
#import "NSDictionary+EMSCore.h"

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
    NSString *eventId = message[@"id"];

    NSArray<NSString *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate keyExists:@"name" withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId errorArray:errors]);
    } else {
        NSString *name = message[@"name"];
        NSDictionary *payload = [message dictionaryValueForKey:@"payload"];
        [self.inAppMessageHandler handleApplicationEvent:name
                                                 payload:payload];
        resultBlock([MEIAMCommandResultUtils createSuccessResultWith:eventId]);
    }
}

@end
