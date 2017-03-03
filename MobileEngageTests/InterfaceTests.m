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

    describe(@"setupWithConfig:launchOptions:", ^{
        it(@"should setup the RequestManager with base64 auth header", ^{
            NSString *applicationId = @"appId";
            NSString *applicationSecret = @"appSecret";
            NSDictionary *additionalHeaders = @{@"Authorization" : [NSString createBasicAuthWith:applicationId password:applicationSecret]};

            id requestManagerMock = [EMSRequestManager mock];
            [[requestManagerMock should] receive:@selector(setAdditionalHeaders:) withArguments:additionalHeaders];

            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder){
                [builder setCredentialsWithApplicationId:applicationId applicationSecret:applicationSecret];
            }];

            [MobileEngage setupWithRequestManager:requestManagerMock config:config launchOptions:nil];
        });
    });

    describe(@"anonymous appLogin", ^{
        it(@"should submit a corresponding RequestModel", ^{

            id requestManagerMock = [EMSRequestManager mock];
            
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder){
                [builder setCredentialsWithApplicationId:@"applicationId" applicationSecret:@"applicationSecret"];
            }];

            [[requestManagerMock should] receive:@selector(setAdditionalHeaders:) withArguments:@{ @"Authorization" : @"Basic YXBwbGljYXRpb25JZDphcHBsaWNhdGlvblNlY3JldA=="}];

            EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"];
                [builder setMethod:HTTPMethodPOST];

                NSDictionary *jsonObject = @{};
                NSData *postBody = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
                [builder setBody:postBody];
            }];


            [[requestManagerMock should] receive:@selector(submit:successBlock:errorBlock:) withArguments:model, nil, nil];
            KWCaptureSpy *spy = [requestManagerMock captureArgument:@selector(submit:successBlock:errorBlock:) atIndex:0];

            [MobileEngage setupWithRequestManager:requestManagerMock config:config launchOptions:nil];
            [MobileEngage appLogin];

            EMSRequestModel *actualModel = spy.argument;
            [[model should] beSimilarWithRequest:actualModel];
        });
    });

SPEC_END
