//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <sqlite3.h>
#import "MEDisplayedIAMFilterByCampaignIdSpecification.h"
#import "MEDisplayedIAMContract.h"

@implementation MEDisplayedIAMFilterByCampaignIdSpecification

- (instancetype)initWithCampaignId:(long)campaignId {
    self = [super init];
    if (self) {
        _campaignId = campaignId;
    }

    return self;
}

- (NSString *)sql {
    return [NSString stringWithFormat:@"WHERE %@ = ?", COLUMN_NAME_CAMPAIGN_ID];
}


- (void)bindStatement:(sqlite3_stmt *)statement {
    sqlite3_bind_int64(statement, 1, self.campaignId);
}

@end