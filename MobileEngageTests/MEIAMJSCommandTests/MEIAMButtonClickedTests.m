#import "Kiwi.h"
#import "MEIAMButtonClicked.h"
#import "MEButtonClickRepository.h"

SPEC_BEGIN(MEIAMButtonClickedTests)

    __block NSString *campaignId;
    __block MEButtonClickRepository *repositoryMock;
    __block MEIAMButtonClicked *meiamButtonClicked;

    beforeEach(^{
        campaignId = @"123";
        repositoryMock = [MEButtonClickRepository mock];
        meiamButtonClicked = [[MEIAMButtonClicked alloc] initWithCampaignId:campaignId repository:repositoryMock];
    });

    describe(@"commandName", ^{

        it(@"should return 'buttonClicked'", ^{
            [[[MEIAMButtonClicked commandName] should] equal:@"buttonClicked"];
        });

    });

    describe(@"handleMessage:resultBlock:", ^{

        it(@"should not accept missing buttonId", ^{
            NSDictionary *dictionary = @{
                    @"id": @"messageId"
            };
            [[repositoryMock shouldNot] receive:@selector(add:)];

            [meiamButtonClicked handleMessage:dictionary resultBlock:nil];
        });

        it(@"should call add on repositoryMock", ^{
            NSString *buttonId = @"789";

            NSDictionary *dictionary = @{
                    @"buttonId": buttonId,
                    @"id": @"messageId"
            };
            KWCaptureSpy *buttonClickSpy = [repositoryMock captureArgument:@selector(add:)
                                                                   atIndex:0];

            NSDate *before = [NSDate date];
            [meiamButtonClicked handleMessage:dictionary resultBlock:nil];
            NSDate *after = [NSDate date];

            MEButtonClick *buttonClick = buttonClickSpy.argument;

            [[buttonClick.buttonId should] equal:buttonId];
            [[buttonClick.campaignId should] equal:campaignId];
            [[buttonClick.timestamp should] beBetween:before and:after];
        });

    });

SPEC_END



