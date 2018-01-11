//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MEDisplayedIAMMapper.h"
#import "MEDisplayedIAM.h"

@implementation MEDisplayedIAMMapper

- (id)modelFromStatement:(sqlite3_stmt *)statement {
    long campaignId = (long) sqlite3_column_int64(statement, 0);
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)];
    return [[MEDisplayedIAM alloc] initWithCampaignId:campaignId timestamp:timestamp];
}

- (sqlite3_stmt *)bindStatement:(sqlite3_stmt *)statement fromModel:(MEDisplayedIAM *)model {
    sqlite3_bind_int64(statement, 1, [model campaignId]);
    sqlite3_bind_double(statement, 2, [[model timestamp] timeIntervalSince1970]);
    return statement;
}

@end