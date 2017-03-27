#import "Kiwi.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"
#import "MobileEngageInternal+Private.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MobileEngageTests)

    id (^mobileEngageInternal)() = ^id() {
        id mobileEngageInternalMock = [MobileEngageInternal mock];

        [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:)];

        NSString *applicationId = kAppId;
        NSString *applicationSecret = @"appSecret";

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationId:applicationId
                                   applicationSecret:applicationSecret];
        }];

        [MobileEngage setupWithMobileEngageInternal:mobileEngageInternalMock
                                             config:config
                                      launchOptions:nil];
        return mobileEngageInternalMock;
    };


    describe(@"Static public interface method", ^{

        it(@"should call internal implementation's method for setupWithConfig:launchOptions:", ^{
            mobileEngageInternal();
        });

        it(@"should call internal implementation's method for setPushToken:", ^{
            NSData *deviceToken = [NSData new];
            [[mobileEngageInternal() should] receive:@selector(setPushToken:) withArguments:deviceToken];

            [MobileEngage setPushToken:deviceToken];
        });

        it(@"should call internal implementation's method for anonymous appLogin", ^{
            [[mobileEngageInternal() should] receive:@selector(appLogin)];

            [MobileEngage appLogin];
        });

        it(@"should call internal implementation's method for appLogin", ^{
            [[mobileEngageInternal() should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)];

            [MobileEngage appLoginWithContactFieldId:@0
                                   contactFieldValue:@"contactFieldValue"];
        });

        it(@"should call internal implementation's method for appLogout", ^{
            [[mobileEngageInternal() should] receive:@selector(appLogout)];

            [MobileEngage appLogout];
        });

        it(@"should call internal implementation's method for trackMessageOpenWithUserInfo", ^{
            [[mobileEngageInternal() should] receive:@selector(trackMessageOpenWithUserInfo:)];

            [MobileEngage trackMessageOpenWithUserInfo:@{}];
        });

        it(@"should call internal implementation's method for trackCustomEvent:eventAttributes:", ^{
            [[mobileEngageInternal() should] receive:@selector(trackCustomEvent:eventAttributes:)];

            [MobileEngage trackCustomEvent:@"eventName"
                           eventAttributes:@{}];
        });
    });

SPEC_END
