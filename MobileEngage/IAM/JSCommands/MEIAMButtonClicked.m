//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import <CoreSDK/NSDictionary+EMSCore.h>
#import <CoreSDK/EMSDictionaryValidator.h>
#import "MEIAMButtonClicked.h"
#import "MEIAMCommandResultUtils.h"

@implementation MEIAMButtonClicked

- (instancetype)initWithCampaignId:(NSString *)campaignId
                        repository:(MEButtonClickRepository *)repository
                      inAppTracker:(id <MEInAppTrackingProtocol>)inAppTracker {
    if (self = [super init]) {
        _campaignId = campaignId;
        _repository = repository;
        _inAppTracker = inAppTracker;
    }
    return self;
}

+ (NSString *)commandName {
    return @"buttonClicked";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {

    NSString *eventId = message[@"id"];
    NSArray<NSDictionary *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate keyExists:@"buttonId" withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId errorArray:errors]);
    }

    NSString *buttonId = [message stringValueForKey:@"buttonId"];
    if (buttonId) {
        [self.repository add:[[MEButtonClick alloc] initWithCampaignId:self.campaignId
                                                              buttonId:buttonId
                                                             timestamp:[NSDate date]]];
        [self.inAppTracker trackInAppClick:self.campaignId buttonId:buttonId];
        resultBlock([MEIAMCommandResultUtils createSuccessResultWith:eventId]);
    } else {
        resultBlock([MEIAMCommandResultUtils createMissingParameterErrorResultWith:eventId
                                                                   missingParameter:@"buttonId"]);
    }
}

@end
