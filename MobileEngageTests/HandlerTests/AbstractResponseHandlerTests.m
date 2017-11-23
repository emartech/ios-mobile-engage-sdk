//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "FakeResponseHandler.h"

SPEC_BEGIN(AbstractResponseHandlerTests)

    describe(@"AbstractResponseHandler", ^{

        it(@"should call handleResponse: when shouldHandleResponse: returns true", ^{
            FakeResponseHandler *fakeResponseHandler = [FakeResponseHandler new];
            fakeResponseHandler.shouldHandle = YES;

            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:nil];

            [fakeResponseHandler processResponse:response];

            [[fakeResponseHandler.handledResponseModel should] equal:response];
        });

        it(@"should not call handleResponse: when shouldHandleResponse: returns false", ^{
            FakeResponseHandler *fakeResponseHandler = [FakeResponseHandler new];
            fakeResponseHandler.shouldHandle = NO;

            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:nil];
            [fakeResponseHandler processResponse:response];

            [[fakeResponseHandler.handledResponseModel should] beNil];
        });

    });

SPEC_END