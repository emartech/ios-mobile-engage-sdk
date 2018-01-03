//
// Copyright (c) 2017 Emarsys. All rights reserved.
//
#import "Kiwi.h"
#import "EMSQueueProtocol.h"
#import "MEDisplayedIAMRepository.h"
#import "MEDisplayedIAMFilterNoneSpecification.h"
#import "MEDisplayedIAMFilterByCampaignIdSpecification.h"
#import "MESchemaDelegate.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestMEDB.db"]

SPEC_BEGIN(StorageTests)

    __block EMSSQLiteHelper *helper;
    __block MEDisplayedIAMRepository *repository;

    beforeEach(^{
        helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH schemaDelegate:[MESchemaDelegate new]];
        [helper open];
        repository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:helper];
    });

    afterEach(^{
        [helper close];
        [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                   error:nil];
    });

    describe(@"repository", ^{
        it(@"should add the element to the database", ^{
            MEDisplayedIAM *displayedIAM = [[MEDisplayedIAM alloc] initWithCampaignId:@"kamp" eventName:@"event" timestamp:[NSDate date]];

            [repository add:displayedIAM];

            NSArray<MEDisplayedIAM *> *items = [repository query:[MEDisplayedIAMFilterNoneSpecification new]];
            [[[items lastObject] should] equal:displayedIAM];
        });

        it(@"should delete element from database", ^{
            MEDisplayedIAM *displayedIAMFirst = [[MEDisplayedIAM alloc] initWithCampaignId:@"kamp1" eventName:@"event1" timestamp:[NSDate date]];
            MEDisplayedIAM *displayedIAMSecond = [[MEDisplayedIAM alloc] initWithCampaignId:@"kamp2" eventName:@"event2" timestamp:[NSDate date]];

            [repository add:displayedIAMFirst];
            [repository add:displayedIAMSecond];

            [repository remove:[[MEDisplayedIAMFilterByCampaignIdSpecification alloc] initWithCampaignId:@"kamp2"]];

            NSArray<MEDisplayedIAM *> *items = [repository query:[MEDisplayedIAMFilterNoneSpecification new]];
            [[[items lastObject] should] equal:displayedIAMFirst];
        });
    });

SPEC_END
