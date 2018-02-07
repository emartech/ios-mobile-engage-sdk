//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSRequestModelBuilder.h>
#import "Kiwi.h"
#import "MEDisplayedIAM.h"
#import "EMSTimestampProvider.h"

SPEC_BEGIN(MEDisplayedIAMTests)

    describe(@"dictionaryRepresentation", ^{
        it(@"should return correct dictionary", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:12345];
            MEDisplayedIAM *display = [[MEDisplayedIAM alloc] initWithCampaignId:@"123" timestamp:date];
            [[[display dictionaryRepresentation] should] equal:@{
                    @"message_id" : @"123",
                    @"timestamp" : [EMSTimestampProvider utcFormattedStringFromDate:date]
            }];
        });
    });

SPEC_END
