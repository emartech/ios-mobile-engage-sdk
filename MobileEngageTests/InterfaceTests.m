#import <CoreSDK/NSString+EMSCore.h>
#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"


SPEC_BEGIN(PublicInterfaceTest)

    registerMatchers(@"EMS");

    id (^requestManagerMock)() = ^id() {
        NSString *applicationId = @"appId";
        NSString *applicationSecret = @"appSecret";
        NSDictionary *additionalHeaders = @{@"Authorization" : [NSString createBasicAuthWith:applicationId
                                                                                    password:applicationSecret]};

        id requestManager = [EMSRequestManager mock];
        [[requestManager should] receive:@selector(setAdditionalHeaders:)
                           withArguments:additionalHeaders];

        MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder){
            [builder setCredentialsWithApplicationId:applicationId
                                   applicationSecret:applicationSecret];
        }];

        [MobileEngage setupWithRequestManager:requestManager
                                       config:config
                                launchOptions:nil];
        return requestManager;
    };

    id (^requestModel)(NSString *url, NSDictionary *body) = ^id(NSString *url, NSDictionary *body) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            NSData *postBody = [NSJSONSerialization dataWithJSONObject:body
                                                               options:0
                                                                 error:nil];
            [builder setBody:postBody];
        }];
    };

    describe(@"setupWithConfig:launchOptions:", ^{
        it(@"should setup the RequestManager with base64 auth header", ^{
            requestManagerMock();
        });
    });

    describe(@"anonymous appLogin", ^{
        it(@"should submit a corresponding RequestModel", ^{
            id requestManager = requestManagerMock();
            EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{});

            [[requestManager should] receive:@selector(submit:successBlock:errorBlock:)
                               withArguments:any(), nil, nil];
            KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:successBlock:errorBlock:)
                                                        atIndex:0];
            [MobileEngage appLogin];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

SPEC_END
