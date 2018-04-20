//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSAuthentication.h>
#import "MEInboxV2.h"
#import "EMSRESTClient.h"
#import "EMSRequestContract.h"
#import "MEInboxParser.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "MEConfig.h"
#import "NSError+EMSCore.h"


@interface MEInboxV2 ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) MEConfig *config;

@end

@implementation MEInboxV2

- (instancetype)initWithConfig:(MEConfig *)config {
    return nil;
}


- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(MEConfig *)config {
    self = [super init];
    if (self) {
        _restClient = restClient;
        _config = config;
    }
    return self;
}


- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
    NSParameterAssert(resultBlock);
    if (self.meId) {
        EMSRequestModel *request = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            NSDictionary *headers = [self createNotificationsFetchingHeaders];
            [[[builder setMethod:HTTPMethodGET] setHeaders:headers] setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@", self.meId]];
        }];
        [_restClient executeTaskWithRequestModel:request
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:nil];
                                        MENotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            resultBlock(status);
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (errorBlock) {
                                                  errorBlock(error);
                                              }
                                          });
                                      }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorBlock) {
                errorBlock([NSError errorWithCode:42
                             localizedDescription:@"MeId is not available."]);
            }
        });
    }
}

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock {

}

- (void)resetBadgeCount {

}

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage {
    return nil;
}

#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"Authorization"] = [EMSAuthentication createBasicAuthWithUsername:self.config.applicationCode
                                                                                     password:self.config.applicationPassword];
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

@end