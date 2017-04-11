#import "Kiwi.h"
#import "MEConfig.h"
#import "MEConfigBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"Builder", ^{

        it(@"should create a config with applicationCode", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:@"pwd"];
            }];

            [[theValue(@"test1") should] equal:theValue(config.applicationCode)];
        });

        it(@"should create a config with applicationPassword", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:@"pwd"];
            }];

            [[theValue(@"pwd") should] equal:theValue(config.applicationPassword)];
        });

        it(@"should throw exception when applicationCode is nil", ^{
            @try {
                [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:nil applicationPassword:@"pwd"];
                }];
                fail(@"Expected Exception when applicationCode is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when secret is nil", ^{
            @try {
                [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:nil];
                }];
                fail(@"Expected Exception when applicationPassword is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END
