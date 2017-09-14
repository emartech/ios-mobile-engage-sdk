#import "Kiwi.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "MobileEngage.h"
#import "MobileEngage+Test.h"
#import "MobileEngage+Private.h"
#import "MobileEngageInternal+Private.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MobileEngageTests)

    id (^mobileEngageInternal)() = ^id() {
        id mobileEngageInternalMock = [MobileEngageInternal mock];

        [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:)];

        NSString *applicationCode = kAppId;
        NSString *applicationPassword = @"appSecret";

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
            [builder setCredentialsWithApplicationCode:applicationCode
                                   applicationPassword:applicationPassword];
        }];

        [MobileEngage setupWithMobileEngageInternal:mobileEngageInternalMock
                                             config:config
                                      launchOptions:nil];
        return mobileEngageInternalMock;
    };

    describe(@"setupWithConfig:launchOptions:", ^{
        it(@"should call internal implementation's method", ^{
            mobileEngageInternal();
        });

        it(@"should create inbox instance", ^{
            mobileEngageInternal();
            [[theValue(MobileEngage.inbox) shouldNot] beNil];
        });

        it(@"should create one inbox instance", ^{
            mobileEngageInternal();
            MEInbox *inbox1 = MobileEngage.inbox;
            MEInbox *inbox2 = MobileEngage.inbox;

            [[inbox1 should] equal:inbox2];
        });
    });

    describe(@"setPushToken:", ^{
        it(@"should call internal implementation's method", ^{
            NSData *deviceToken = [NSData new];
            [[mobileEngageInternal() should] receive:@selector(setPushToken:) withArguments:deviceToken];

            [MobileEngage setPushToken:deviceToken];
        });
    });

    describe(@"anonymous appLogin", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(appLogin)];

            [MobileEngage appLogin];
        });
    });

    describe(@"appLoginWithContactFieldId:contactFieldValue:", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)];

            [MobileEngage appLoginWithContactFieldId:@0
                                   contactFieldValue:@"contactFieldValue"];
        });

        it(@"should set the contactFieldId and contactFieldValue in inbox", ^{
            [MobileEngage setupWithMobileEngageInternal:[MobileEngageInternal nullMock] config:[MEConfig nullMock] launchOptions:nil];
            [MobileEngage appLoginWithContactFieldId:@5
                                   contactFieldValue:@"three"];

            [[MobileEngage.inbox.appLoginParameters.contactFieldId should] equal:@5];
            [[MobileEngage.inbox.appLoginParameters.contactFieldValue should] equal:@"three"];
        });
    });

    describe(@"appLogout", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(appLogout)];

            [MobileEngage appLogout];
        });
    });

    describe(@"trackMessageOpenWithUserInfo:", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(trackMessageOpenWithUserInfo:)];

            [MobileEngage trackMessageOpenWithUserInfo:@{}];
        });
    });

    describe(@"trackMessageOpenWithInboxMessage:", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(trackMessageOpenWithInboxMessage:)];
            MENotification *message = [MENotification new];
            message.id = @"testID";
            [MobileEngage trackMessageOpenWithInboxMessage:message];
        });
    });

    describe(@"trackCustomEvent:eventAttributes:", ^{
        it(@"should call internal implementation's method", ^{
            [[mobileEngageInternal() should] receive:@selector(trackCustomEvent:eventAttributes:)];

            [MobileEngage trackCustomEvent:@"eventName"
                           eventAttributes:@{}];
        });
    });

SPEC_END
