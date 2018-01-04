#import "Kiwi.h"
#import "MEInApp.h"
#import "MEInApp+Private.h"
#import "FakeInAppHandler.h"

MEInApp *iam;

SPEC_BEGIN(MEIAMTests)

    beforeEach(^{
        iam = [[MEInApp alloc] init];
    });

    describe(@"rootViewController", ^{

        it(@"should not be nil", ^{
            UIViewController *rootViewController = [iam rootViewController];
            [[rootViewController shouldNot] beNil];
        });

    });

    describe(@"topViewController", ^{

        it(@"should not be nil", ^{
            UIViewController *topViewController = [iam topViewController];
            [[topViewController shouldNot] beNil];
        });

        it(@"should return rootViewController, when there is no more presented ViewController", ^{
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"];

            [[[iam rootViewController] presentedViewController] dismissViewControllerAnimated:NO completion:^{
                [exp fulfill];
            }];
            [XCTWaiter waitForExpectations:@[exp]
                                   timeout:30];

            UIViewController *topViewController = [iam topViewController];
            [[topViewController should] equal:[iam rootViewController]];

        });

        it(@"should return the presentedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *presentedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:presentedViewController];
            [presentedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:presentedViewController];
        });

        it(@"should return the nestedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *presentedViewController = [UIViewController mock];
            UIViewController *nestedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:presentedViewController];
            [presentedViewController stub:@selector(presentedViewController) andReturn:nestedViewController];
            [nestedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:nestedViewController];
        });

        it(@"should return the lastViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *navigationController = [UINavigationController mock];
            UIViewController *viewControllerLast = [UIViewController mock];
            NSArray *viewControllers = @[[UIViewController mock], viewControllerLast];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:navigationController];
            [navigationController stub:@selector(presentedViewController)];
            [navigationController stub:@selector(viewControllers) andReturn:viewControllers];
            [viewControllerLast stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:viewControllerLast];
        });

        it(@"should return the selectedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *tabBarController = [UITabBarController mock];
            UIViewController *selectedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:tabBarController];
            [tabBarController stub:@selector(presentedViewController)];
            [tabBarController stub:@selector(selectedViewController) andReturn:selectedViewController];
            [selectedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:selectedViewController];
        });
    });

    describe(@"messageHandler", ^{
        it(@"should pass the eventName and payload to the given messageHandler's handleApplicationEvent:payload: method", ^{
            NSString *expectedName = @"nameOfTheEvent";
            NSDictionary <NSString *, NSObject *> *expectedPayload = @{
                    @"payloadKey1": @{
                            @"payloadKey2": @"payloadValue"
                    }
            };

            FakeInAppHandler *inAppHandler = [FakeInAppHandler mock];
            [iam setMessageHandler:inAppHandler];
            NSString *message = @"<!DOCTYPE html>\n"
                    "<html lang=\"en\">\n"
                    "  <head>\n"
                    "    <script>\n"
                    "      window.onload = function() {\n"
                    "        window.webkit.messageHandlers.triggerAppEvent.postMessage({id: '1', name: 'nameOfTheEvent', payload:{payloadKey1:{payloadKey2: 'payloadValue'}}});\n"
                    "      };\n"
                    "    </script>\n"
                    "  </head>\n"
                    "  <body style=\"background: transparent;\">\n"
                    "  </body>\n"
                    "</html>";
            [[inAppHandler shouldEventually] receive:@selector(handleApplicationEvent:payload:)
                                       withArguments:expectedName, expectedPayload];

            [iam showMessage:[[MEInAppMessage alloc] initWithResponseParsedBody:@{@"message": @{@"id": @"campaignId", @"html": message}}]];
        });
    });

SPEC_END
