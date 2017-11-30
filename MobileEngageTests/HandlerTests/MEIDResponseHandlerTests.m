//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MEIDResponseHandler.h"
#import "AbstractResponseHandler+Private.h"
#import "MobileEngageInternal.h"

SPEC_BEGIN(MEIDResponseHandlerTests)

    describe(@"MEIdResponseHandler.shouldHandleResponse", ^{

        it(@"should return YES when the response contains MEID", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": @"id123456789"} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIdResponseHandler *handler = [MEIdResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beYes];
        });

        it(@"should return NO when the response lacks MEID", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIdResponseHandler *handler = [MEIdResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beNo];
        });

    });

    describe(@"MEIdResponseHandler.handleResponse", ^{

        it(@"should call setMEID on MobileEngageInternal", ^{
            NSString *meId = @"id123456789";
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": meId} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];
            
            id mobileEngageInternalMock = [MobileEngageInternal mock];
            [[mobileEngageInternalMock should] receive:@selector(setMeId:) withArguments:meId];
            MEIdResponseHandler *handler = [[MEIdResponseHandler alloc] initWithMobileEngageInternal:mobileEngageInternalMock];

            [handler handleResponse:response];
        });

    });

SPEC_END