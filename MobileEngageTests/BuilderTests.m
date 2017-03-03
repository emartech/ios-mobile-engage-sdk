#import "Kiwi.h"
#import "MEConfig.h"
#import "MEConfigBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"Builder", ^{

        it(@"should create a config with applicationId", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"test1" applicationSecret:@"pwd"];
            }];

            [[theValue(@"test1") should] equal:theValue(config.applicationId)];
        });

        it(@"should create a config with applicationSecret", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"test1" applicationSecret:@"pwd"];
            }];

            [[theValue(@"pwd") should] equal:theValue(config.applicationSecret)];
        });

        it(@"should throw exception when applicationId is nil", ^{
            @try {
                [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationId:nil applicationSecret:@"pwd"];
                }];
                fail(@"Expected Exception when applicationId is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when secret is nil", ^{
            @try {
                [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationId:@"test1" applicationSecret:nil];
                }];
                fail(@"Expected Exception when applicationSecret is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END
