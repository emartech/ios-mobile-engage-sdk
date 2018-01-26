//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSRequestModelBuilder.h>
#import "Kiwi.h"
#import "MEButtonClick.h"

SPEC_BEGIN(MEButtonClickTests)


    describe(@"dictionaryRepresentation", ^{

        it(@"should return correct dictionary", ^{
            MEButtonClick *click = [[MEButtonClick alloc] initWithCampaignId:@"123" buttonId:@"456" timestamp:[NSDate dateWithTimeIntervalSince1970:12345]];
            [[[click dictionaryRepresentation] should] equal:@{
                    @"message_id" : @"123",
                    @"button_id" : @"456",
                    @"timestamp" : @12345000
            }];
        });

        it(@"should return correct dictionary with fractions", ^{
            MEButtonClick *click = [[MEButtonClick alloc] initWithCampaignId:@"123" buttonId:@"456" timestamp:[NSDate dateWithTimeIntervalSince1970:12345.5]];
            [[[click dictionaryRepresentation] should] equal:@{
                    @"message_id" : @"123",
                    @"button_id" : @"456",
                    @"timestamp" : @12345500
            }];
        });



    });

SPEC_END
