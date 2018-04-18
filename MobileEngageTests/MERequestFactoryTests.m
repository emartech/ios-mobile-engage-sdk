#import <CoreSDK/EMSDeviceInfo.h>
#import "Kiwi.h"
#import "MERequestFactory.h"
#import "EMSRequestModel.h"
#import "MobileEngageVersion.h"
#import "EMSRequestModelMatcher.h"
#import "MERequestContext.h"
#import "MEConfigBuilder.h"
#import "MEExperimental+Test.h"

SPEC_BEGIN(MERequestFactoryTests)

#define kLastMobileActivityURL @"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"
#define kAppLoginURL @"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"

        registerMatchers(@"EMS");

        afterAll(^{
            [MEExperimental reset];
        });

        describe(@"createTrackDeepLinkRequestWithTrackingId:", ^{
            it(@"should create a RequestModel with deepLinkValue", ^{

                NSString *const value = @"dl_value";
                NSString *userAgent = [NSString stringWithFormat:@"Mobile Engage SDK %@ %@ %@", MOBILEENGAGE_SDK_VERSION, [EMSDeviceInfo deviceType], [EMSDeviceInfo osVersion]];
                EMSRequestModel *expected = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setMethod:HTTPMethodPOST];
                    [builder setUrl:@"https://deep-link.eservice.emarsys.net/api/clicks"];
                    [builder setHeaders:@{@"User-Agent": userAgent}];
                    [builder setPayload:@{@"ems_dl": value}];
                }];

                EMSRequestModel *result = [MERequestFactory createTrackDeepLinkRequestWithTrackingId:value];
                [[result should] beSimilarWithRequest:expected];
            });

        });


        describe(@"createLoginOrLastMobileActivityRequestWithPushToken:requestContext:", ^{

            __block MEConfig *config;
            __block NSString *applicationCode;
            __block NSString *password;
            __block NSMutableDictionary *apploginPayload;



            beforeEach(^{
                config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                           applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                }];
                applicationCode = @"14C19-A121F";
                password = @"PaNkfOD90AVpYimMBuZopCpm8OWCrREu";

                apploginPayload = [NSMutableDictionary new];
                apploginPayload[@"platform"] = @"ios";
                apploginPayload[@"language"] = [EMSDeviceInfo languageCode];
                apploginPayload[@"timezone"] = [EMSDeviceInfo timeZone];
                apploginPayload[@"device_model"] = [EMSDeviceInfo deviceModel];
                apploginPayload[@"os_version"] = [EMSDeviceInfo osVersion];
                apploginPayload[@"ems_sdk"] = MOBILEENGAGE_SDK_VERSION;
                apploginPayload[@"application_id"] = applicationCode;
                apploginPayload[@"hardware_id"] = [EMSDeviceInfo hardwareId];

                NSString *appVersion = [EMSDeviceInfo applicationVersion];
                if (appVersion) {
                    apploginPayload[@"application_version"] = appVersion;
                }
                apploginPayload[@"push_token"] = @NO;
            });

            context(@"INAPP TURNED OFF", ^{

                beforeEach(^{
                    [MEExperimental reset];
                });

                it(@"should result in applogin request if there was no previous applogin", ^{
                    MERequestContext *requestContext = [MERequestContext new];
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:@3 contactFieldValue:@"test@test.com"];


                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });

                it(@"should result in lastMobileActivity request if there was previous applogin with same payload", ^{
                    MERequestContext *requestContext = [MERequestContext new];
                    requestContext.config = config;
                    NSNumber *contactFieldId = @3;
                    NSString *contactFieldValue = @"test@test.com";
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];

                    apploginPayload[@"contact_field_id"] = contactFieldId;
                    apploginPayload[@"contact_field_value"] = contactFieldValue;
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kLastMobileActivityURL];
                });

                it(@"should result in applogin request if there was previous applogin with different payload", ^{
                    MERequestContext *requestContext = [MERequestContext new];
                    requestContext.config = config;
                    NSNumber *contactFieldId = @3;
                    NSString *contactFieldValue = @"test@test.com";
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];

                    apploginPayload[@"contact_field_id"] = contactFieldId;
                    apploginPayload[@"contact_field_value"] = contactFieldValue;
                    apploginPayload[@"application_version"] = @"changed";
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });
            });

            context(@"INAPP TURNED ON", ^{

                beforeEach(^{
                    config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                        [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                               applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                    }];
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                });

                it(@"should result in applogin request if there was previous applogin with same payload and there is no meid", ^{
                    NSNumber *contactFieldId = @3;
                    NSString *contactFieldValue = @"test@test.com";
                    apploginPayload[@"contact_field_id"] = contactFieldId;
                    apploginPayload[@"contact_field_value"] = contactFieldValue;

                    MERequestContext *requestContext = [MERequestContext new];
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });

                it(@"should result in lastMobileActivity request if there was previous applogin with same payload and there is an existing meid", ^{
                    NSNumber *contactFieldId = @3;
                    NSString *contactFieldValue = @"test@test.com";
                    apploginPayload[@"contact_field_id"] = contactFieldId;
                    apploginPayload[@"contact_field_value"] = contactFieldValue;

                    MERequestContext *requestContext = [MERequestContext new];
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = @"something";

                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kLastMobileActivityURL];
                });
            });

        });

SPEC_END