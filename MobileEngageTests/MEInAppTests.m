#import "Kiwi.h"
#import "MEInApp.h"
#import "MEInApp+Private.h"
#import "FakeInAppHandler.h"
#import "MEIAMProtocol.h"
#import "KWNilMatcher.h"

MEInApp *iam;

SPEC_BEGIN(MEInAppTests)

    beforeEach(^{
        iam = [[MEInApp alloc] init];
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

        it(@"should not try to display inapp in case if there is already one being displayed", ^{
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
            [[inAppHandler shouldEventually] receive:@selector(handleApplicationEvent:payload:) withCountAtMost:1 arguments:expectedName, expectedPayload];


            [iam showMessage:[[MEInAppMessage alloc] initWithResponseParsedBody:@{@"message": @{@"id": @"campaignId", @"html": message}}]];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [iam showMessage:[[MEInAppMessage alloc] initWithResponseParsedBody:@{@"message": @{@"id": @"campaignId", @"html": message}}]];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        });
    });


    describe(@"showMessage", ^{
        it(@"it should set currentCampaignId", ^{
            MEInApp *meInApp = [MEInApp new];
            [meInApp showMessage:[[MEInAppMessage alloc] initWithResponseParsedBody:@{@"message":@{@"id":@"testId", @"html" : @"<html></html>"}}]];
            [[[((id <MEIAMProtocol>) meInApp) currentCampaignId] should] equal:@"testId"];
        });

        it(@"should call trackInAppDisplay: on inAppTracker", ^{
            id inAppTracker = [KWMock mockForProtocol:@protocol(MEInAppTrackingProtocol)];
            [[inAppTracker should] receive:@selector(trackInAppDisplay:) withArguments:@"testId"];
            iam.inAppTracker = inAppTracker;
            [iam showMessage:[[MEInAppMessage alloc] initWithResponseParsedBody:@{@"message":@{@"id":@"testId", @"html" : @"<html></html>"}}]];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        });
    });

    describe(@"closeInAppMessage", ^{

        it(@"should close the inapp message", ^{
            UIViewController *rootViewControllerMock = [UIViewController nullMock];
            [[rootViewControllerMock should] receive:@selector(dismissViewControllerAnimated:completion:)];
            KWCaptureSpy *spy = [rootViewControllerMock captureArgument:@selector(dismissViewControllerAnimated:completion:) atIndex:1];

            UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            window.rootViewController = rootViewControllerMock;

            MEInApp *meInApp = [MEInApp new];
            meInApp.iamWindow = window;

            [((id <MEIAMProtocol>) meInApp) closeInAppMessage];

            void (^completionBlock)(void) = spy.argument;
            completionBlock();
            [[meInApp.iamWindow should] beNil];
        });

    });

SPEC_END
