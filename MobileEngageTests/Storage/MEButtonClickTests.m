//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSRequestModelBuilder.h>
#import "Kiwi.h"
#import "MEButtonClick.h"
#import "EMSTimestampProvider.h"

SPEC_BEGIN(MEButtonClickTests)

    describe(@"dictionaryRepresentation", ^{
        it(@"should return correct dictionary", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:12345];
            MEButtonClick *click = [[MEButtonClick alloc] initWithCampaignId:@"123" buttonId:@"456" timestamp:date];
            [[[click dictionaryRepresentation] should] equal:@{
                    @"message_id" : @"123",
                    @"button_id" : @"456",
                    @"timestamp" : [EMSTimestampProvider utcFormattedStringFromDate:date]
            }];
        });
    });

SPEC_END
