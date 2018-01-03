//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#define TABLE_NAME @"displayed_iam"
#define COLUMN_NAME_CAMPAIGN_ID @"campaign_id"
#define COLUMN_NAME_EVENT_NAME @"event_name"
#define COLUMN_NAME_TIMESTAMP @"timestamp"

#define SQL_CREATE_TABLE [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT, %@ DOUBLE);", TABLE_NAME, COLUMN_NAME_CAMPAIGN_ID, COLUMN_NAME_EVENT_NAME, COLUMN_NAME_TIMESTAMP]
#define SQL_INSERT [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@) VALUES (?, ?, ?);", TABLE_NAME, COLUMN_NAME_CAMPAIGN_ID, COLUMN_NAME_EVENT_NAME, COLUMN_NAME_TIMESTAMP]
#define SQL_SELECT(filter) [NSString stringWithFormat:@"SELECT * FROM %@ %@;", TABLE_NAME, filter]
#define SQL_DELETE_ITEM(filter) [NSString stringWithFormat:@"DELETE FROM %@ %@;", TABLE_NAME, filter]
#define SQL_PURGE [NSString stringWithFormat:@"DELETE FROM %@;", TABLE_NAME]
#define SQL_COUNT [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;", TABLE_NAME]
