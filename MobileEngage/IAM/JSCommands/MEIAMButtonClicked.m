//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEIAMButtonClicked.h"
#import "MEIAMCommamndResultUtils.h"

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
    NSString *buttonId = message[@"buttonId"];
    NSString *eventId = message[@"id"];
    if (buttonId) {
        [self.repository add:[[MEButtonClick alloc] initWithCampaignId:self.campaignId
                                                              buttonId:buttonId
                                                             timestamp:[NSDate date]]];
        [self.inAppTracker trackInAppClick:self.campaignId buttonId:buttonId];
        resultBlock([MEIAMCommamndResultUtils createSuccessResultWith:eventId]);
    } else {
        resultBlock([MEIAMCommamndResultUtils createMissingParameterErrorResultWith:eventId
                                                                   missingParameter:@"buttonId"]);
    }
}

@end
