//
// Copyright (c) 2017 Emarsys. All rights reserved.
//
#import "Kiwi.h"
#import "EMSQueueProtocol.h"
#import "EMSInMemoryQueue.h"
#import "EMSRequestModelBuilder.h"

SPEC_BEGIN(QueueTests)

    beforeEach(^{

    });

    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    id (^createQueue)() = ^id <EMSQueueProtocol>() {
        return [EMSInMemoryQueue new];
    };

    describe(@"pop", ^{
        it(@"should return nil when the queue is empty", ^{
            id <EMSQueueProtocol> queue = createQueue();

            [[[queue pop] should] beNil];
        });
    });

    describe(@"push:", ^{
        it(@"should assert for nil parameter", ^{
            id <EMSQueueProtocol> queue = createQueue();
            @try {
                [queue push:nil];
                fail(@"Expected Exception when model is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });
    });

    describe(@"push:", ^{
        it(@"should add an item to the queue", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = [EMSRequestModel new];
            [queue push:firstModel];

            [[[queue pop] should] equal:firstModel];
        });
    });

    describe(@"pushAndPop", ^{
        it(@"should keep the order of the elements", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = requestModel(@"https://url1.com", nil);
            EMSRequestModel *secondModel = requestModel(@"https://url2.com", nil);

            [queue push:firstModel];
            [queue push:secondModel];

            [[[queue pop] should] equal:firstModel];
            [[[queue pop] should] equal:secondModel];
        });
    });

    describe(@"pushFirst:", ^{
        it(@"should add to the beginning of the queue", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = requestModel(@"https://url1.com", nil);
            EMSRequestModel *secondModel = requestModel(@"https://url2.com", nil);

            [queue push:secondModel];
            [queue pushFirst:firstModel];

            [[[queue pop] should] equal:firstModel];
        });
    });

SPEC_END