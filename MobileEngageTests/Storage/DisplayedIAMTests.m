//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSRequestModelBuilder.h>
#import "Kiwi.h"
#import "MEDisplayedIAM.h"

SPEC_BEGIN(MEDisplayedIAMTests)

    describe(@"dictionaryRepresentation", ^{
        it(@"should return correct dictionary", ^{
            MEDisplayedIAM *display = [[MEDisplayedIAM alloc] initWithCampaignId:@"123" timestamp:[NSDate dateWithTimeIntervalSince1970:12345]];
            [[[display dictionaryRepresentation] should] equal:@{
                    @"message_id" : @"123",
                    @"timestamp" : @12345000
            }];
        });
    });

SPEC_END
