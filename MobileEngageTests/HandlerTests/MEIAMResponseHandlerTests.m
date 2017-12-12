//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "MEIDResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "AbstractResponseHandler+Private.h"
#import "MEInApp.h"
#import "MobileEngage+Test.h"

SPEC_BEGIN(MEIAMResponseHandlerTests)

    describe(@"MEIAMResponseHandler.shouldHandleResponse", ^{

        it(@"should return YES when the response contains html message", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"html" : @"<html><body style=\"background-color:red\"></body></html>"}} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beYes];
        });

        it(@"should return NO when the response lacks html message", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beNo];
        });

        it(@"should return NO when the response lacks html inside message", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message" : @{}} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beNo];
        });

        it(@"should return NO when the response lacks body", ^{
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:nil];

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beNo];
        });

        it(@"should return NO when the response contains message as a string", ^{
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message" : @"whatever"} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];

            [[theValue([handler shouldHandleResponse:response]) should] beNo];
        });

    });

    describe(@"MEIAMResponseHandler.handleResponse", ^{

        it(@"should call showMessage on MEInApp", ^{
            NSString *html = @"<html><body style=\"background-color:red\"></body></html>";
            NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"html" : html}} options:0 error:nil];
            EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200 headers:@{} body:body];

            id iamMock = [MEInApp mock];
            [[iamMock should] receive:@selector(showMessage:) withArguments:html];
            MobileEngage.inApp = iamMock;

            MEIAMResponseHandler *handler = [MEIAMResponseHandler new];
            [handler handleResponse:response];
        });

    });

SPEC_END