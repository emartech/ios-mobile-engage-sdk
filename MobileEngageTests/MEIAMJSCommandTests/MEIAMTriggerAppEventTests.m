#import "Kiwi.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEInAppMessageHandler.h"

@interface InAppHandler : NSObject <MEInAppMessageHandler>

@end

@implementation InAppHandler

- (void)handleApplicationEvent:(NSString *)eventName
                       payload:(nullable NSDictionary *)payload {
}

@end

SPEC_BEGIN(MEIAMTriggerAppEventTests)

    beforeEach(^{
    });

    describe(@"commandName", ^{

        it(@"should return 'triggerAppEvent'", ^{
            [[[MEIAMTriggerAppEvent commandName] should] equal:@"triggerAppEvent"];
        });

    });

    describe(@"handleMessage:resultBlock:", ^{

        it(@"should pass the eventName and payload to the given inAppMessageHandler's handleApplicationEvent:payload: method", ^{
            InAppHandler *inAppHandler = [InAppHandler mock];
            NSString *eventName = @"nameOfTheEvent";
            NSDictionary <NSString *, NSObject *> *payload = @{
                    @"payloadKey1": @{
                            @"payloadKey2": @"payloadValue"
                    }
            };
            NSDictionary *scriptMessage = @{
                    @"name": eventName,
                    @"payload": payload
            };

            MEIAMTriggerAppEvent *appEvent = [[MEIAMTriggerAppEvent alloc] initWithInAppMessageHandler:inAppHandler];

            [[inAppHandler should] receive:@selector(handleApplicationEvent:payload:) withArguments:eventName, payload];

            [appEvent handleMessage:scriptMessage
                        resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                        }];
        });

        it(@"should receive success in resultBlock", ^{
            MEIAMTriggerAppEvent *appEvent = [MEIAMTriggerAppEvent new];

            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
            __block NSDictionary<NSString *, NSObject *> *returnedResult;
            [appEvent handleMessage:@{@"name": @"name"}
                        resultBlock:^(NSDictionary<NSString *, NSObject *> *result) {
                            returnedResult = result;
                            [exp fulfill];
                        }];
            [XCTWaiter waitForExpectations:@[exp] timeout:30];

            [[returnedResult should] equal:@{@"success": @YES}];
        });

    });

SPEC_END



