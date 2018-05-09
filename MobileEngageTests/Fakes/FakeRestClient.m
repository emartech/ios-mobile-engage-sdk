//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSTimestampProvider.h>
#import "FakeRestClient.h"
#import "EMSResponseModel.h"
#import "NSError+EMSCore.h"

@interface FakeRestClient ()

@property(nonatomic, assign) ResultType resultType;

@end

@implementation FakeRestClient

- (instancetype)initWithResultType:(ResultType)resultType {
    if (self = [super init]) {
        _resultType = resultType;
        _submittedRequests = [NSMutableArray new];
    }
    return self;
}

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                       successBlock:(CoreSuccessBlock)successBlock
                         errorBlock:(CoreErrorBlock)errorBlock {
    [self.submittedRequests addObject:requestModel];
    NSDictionary *jsonResponse = @{@"notifications": @[
        @{@"id": @"id1", @"title": @"title1", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678129)},
        @{@"id": @"id2", @"title": @"title2", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678128)},
        @{@"id": @"id3", @"title": @"title3", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678127)},
        @{@"id": @"id4", @"title": @"title4", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678126)},
        @{@"id": @"id5", @"title": @"title5", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678125)},
        @{@"id": @"id6", @"title": @"title6", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678124)},
        @{@"id": @"id7", @"title": @"title7", @"custom_data": @{}, @"root_params": @{}, @"expiration_time": @7200, @"received_at": @(12345678123)},
    ],
        @"badge_count": @3
    };
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:[NSJSONSerialization dataWithJSONObject:jsonResponse
                                                                                                              options:0
                                                                                                                error:nil]
                                                                 requestModel:[EMSRequestModel new]
                                                                    timestamp:[NSDate date]];
    NSError *error = [NSError errorWithCode:500 localizedDescription:@"FakeError"];


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.resultType == ResultTypeSuccess) {
            successBlock(requestModel.requestId, response);
        } else {
            errorBlock(requestModel.requestId, error);
        }
    });
}

@end