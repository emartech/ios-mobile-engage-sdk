//
//  Created by Laszlo Ori on 2017. 03. 22..
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "FakeStatusDelegate.h"
#import "MobileEngage.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"

SPEC_BEGIN(IntegrationTests)

    FakeStatusDelegate *(^createStatusDelegate)() = ^FakeStatusDelegate *() {
        FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];
        statusDelegate.printErrors = YES;
        return statusDelegate;
    };

    describe(@"Public interface methods", ^{
        it(@"should return with eventId, and finish with success for anonymousAppLogin", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLogin];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for appLogin", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLoginWithContactFieldId:@123456789
                                                       contactFieldValue:@"contactFieldValue"];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackMessageOpen", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"}];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent without attributes", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:nil];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent with attributes", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:@{
                                                       @"animal": @"cat",
                                                       @"drink": @"palinka",
                                                       @"food": @"pizza"
                                               }];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for appLogout", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationId:@"14C19-A121F"
                                       applicationSecret:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLogout];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });
    });

SPEC_END
