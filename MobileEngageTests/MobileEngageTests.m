#import "Kiwi.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "MobileEngage.h"
#import "MobileEngage+Test.h"
#import "MobileEngage+Private.h"
#import "MobileEngageInternal+Private.h"
#import "MEInApp+Private.h"

static NSString *const kAppId = @"kAppId";

SPEC_BEGIN(MobileEngageTests)

        id (^mobileEngageInternal)() = ^id() {
            id mobileEngageInternalMock = [MobileEngageInternal mock];

            [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:)];
            [[mobileEngageInternalMock should] receive:@selector(setNotificationCenterManager:) withArguments:kw_any()];

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

        describe(@"setupWithConfig:launchOptions:inApp:requestRepositoryFactory:", ^{
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

            it(@"should create inApp instance", ^{
                mobileEngageInternal();

                [[MobileEngage.inApp shouldNot] beNil];
            });

            it(@"should create MENotificationCenterManager instance", ^{
                id mobileEngageInternalMock = [MobileEngageInternal mock];
                [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:)];
                [[mobileEngageInternalMock should] receive:@selector(setNotificationCenterManager:) withArguments:kw_any()];
                KWCaptureSpy *spy = [mobileEngageInternalMock captureArgument:@selector(setNotificationCenterManager:) atIndex:0];

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";

                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [MobileEngage setupWithMobileEngageInternal:mobileEngageInternalMock
                                                     config:config
                                              launchOptions:nil];

                [[spy.argument shouldNot] beNil];
            });

            it(@"should assign tracker to MEInApp", ^{
                mobileEngageInternal();
                [[(NSObject *) MobileEngage.inApp.inAppTracker shouldNot] beNil];
            });

            it(@"should call internal's setup with non-null logRepository", ^{
                id mobileEngageInternalMock = [MobileEngageInternal nullMock];
                [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:)];
                KWCaptureSpy *spy = [mobileEngageInternalMock captureArgument:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:) atIndex:3];

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";

                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [MobileEngage setupWithMobileEngageInternal:mobileEngageInternalMock
                                                     config:config
                                              launchOptions:nil];

                [[spy.argument shouldNot] beNil];
            });

            it(@"should set logRepository on MEInApp instance", ^{
                id mobileEngageInternalMock = [MobileEngageInternal nullMock];
                [[mobileEngageInternalMock should] receive:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:)];
                KWCaptureSpy *spy = [mobileEngageInternalMock captureArgument:@selector(setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:) atIndex:3];

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";

                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [MobileEngage setupWithMobileEngageInternal:mobileEngageInternalMock
                                                     config:config
                                              launchOptions:nil];

                [[MobileEngage.inApp.logRepository should] equal:spy.argument];
            });

            it(@"should set timestampProvider on MEInApp instance", ^{
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";

                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [MobileEngage setupWithMobileEngageInternal:[MobileEngageInternal nullMock]
                                                     config:config
                                              launchOptions:nil];

                [[MobileEngage.inApp.timestampProvider shouldNot] beNil];
            });
        });

        describe(@"trackDeepLinkWith:sourceHandler:", ^{
            it(@"should call internal implementation's method", ^{
                NSUserActivity *userActivity = [NSUserActivity mock];
                MESourceHandler sourceHandler = ^(NSString *source) {
                };
                [[mobileEngageInternal() should] receive:@selector(trackDeepLinkWith:sourceHandler:)
                                           withArguments:userActivity, sourceHandler];

                [MobileEngage trackDeepLinkWith:userActivity
                                  sourceHandler:sourceHandler];
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

                [[((MEInbox*)MobileEngage.inbox).appLoginParameters.contactFieldId should] equal:@5];
                [[((MEInbox*)MobileEngage.inbox).appLoginParameters.contactFieldValue should] equal:@"three"];
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
