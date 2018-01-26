//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSRequestModelBuilder.h>
#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "MERequestTools.h"

SPEC_BEGIN(EMSRequestToolsTests)


    describe(@"isCustomEvent", ^{

        it(@"should return YES if the request is a custom event", ^{
            EMSRequestModel *customEvent = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://ems-me-deviceevent.herokuapp.com/v3/devices/2398732872/events"];
            }];

            [[theValue([MERequestTools isRequestCustomEvent:customEvent]) should] beYes];
        });

        it(@"should return NO if the request is a NOT custom event", ^{
            EMSRequestModel *customEvent = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://ems-me-deviceevent.herokuapp.com/v3/devices/2398732872/events2"];
            }];

            [[theValue([MERequestTools isRequestCustomEvent:customEvent]) should] beNo];
        });


    });

SPEC_END
