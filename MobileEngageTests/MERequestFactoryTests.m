#import <CoreSDK/EMSDeviceInfo.h>
#import "Kiwi.h"
#import "MERequestFactory.h"
#import "EMSRequestModel.h"
#import "MobileEngageVersion.h"
#import "EMSRequestModelMatcher.h"

SPEC_BEGIN(MERequestFactoryTests)

    registerMatchers(@"EMS");

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

SPEC_END
