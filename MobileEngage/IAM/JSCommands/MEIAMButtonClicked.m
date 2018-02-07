//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEIAMButtonClicked.h"
#import "MEIAMCommamndResultUtils.h"

@implementation MEIAMButtonClicked

- (instancetype)initWithCampaignId:(NSString *)campaignId
                        repository:(MEButtonClickRepository *)repository {
    if (self = [super init]) {
        _campaignId = campaignId;
        _repository = repository;
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
        [_repository add:[[MEButtonClick alloc] initWithCampaignId:_campaignId
                                                          buttonId:buttonId
                                                         timestamp:[NSDate date]]];
        resultBlock([MEIAMCommamndResultUtils createSuccessResultWith:eventId]);
    } else {
        resultBlock([MEIAMCommamndResultUtils createMissingParameterErrorResultWith:eventId
                                                                   missingParameter:@"buttonId"]);
    }
}

@end
