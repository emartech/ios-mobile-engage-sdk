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
@property(nonatomic, strong) NSMutableArray *notifications;

@end

@implementation MEInboxV2

- (instancetype)initWithConfig:(MEConfig *)config {
    EMSRESTClient *restClient = [EMSRESTClient clientWithSession:[NSURLSession sharedSession]];
    return [self initWithRestClient:restClient
                             config:config];
}


- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(MEConfig *)config {
    self = [super init];
    if (self) {
        _restClient = restClient;
        _config = config;
        _notifications = [NSMutableArray array];
    }
    return self;
}


- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
    NSParameterAssert(resultBlock);
    if (self.meId) {
        __weak typeof(self) weakSelf = self;
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodGET];
            [builder setHeaders:[weakSelf createNotificationsFetchingHeaders]];
            [builder setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@", weakSelf.meId]];
        }];
        [_restClient executeTaskWithRequestModel:requestModel
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:nil];
                                        MENotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            resultBlock([weakSelf mergedStatusWithStatus:status]);
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [weakSelf respondWithError:errorBlock error:error];
                                      }];
    } else {
        [self handleNoMeIdWithErrorBlock:errorBlock];
    }
}

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock {
    if (self.meId) {
        __weak typeof(self) weakSelf = self;
        EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodPOST];
            [builder setHeaders:[weakSelf createNotificationsFetchingHeaders]];
            [builder setUrl:[NSString stringWithFormat:@"https://me-inbox.eservice.emarsys.net/api/v1/notifications/%@/count", weakSelf.meId]];
        }];
        [_restClient executeTaskWithRequestModel:requestModel
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (successBlock) {
                                                successBlock();
                                            }
                                        });
                                    }
                                      errorBlock:^(NSString *requestId, NSError *error) {
                                          [weakSelf respondWithError:errorBlock error:error];
                                      }];
    } else {
        [self handleNoMeIdWithErrorBlock:errorBlock];
    }
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithSuccessBlock:nil errorBlock:nil];
}

- (void)addNotification:(MENotification *)notification {
    [self.notifications insertObject:notification
                             atIndex:0];
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

- (MENotificationInboxStatus *)mergedStatusWithStatus:(MENotificationInboxStatus *)status {
    [self invalidateCachedNotifications:status];

    NSMutableArray *statusNotifications = [NSMutableArray new];
    [statusNotifications addObjectsFromArray:self.notifications];
    [statusNotifications addObjectsFromArray:status.notifications];
    status.notifications = statusNotifications;
    return status;
}

- (void)invalidateCachedNotifications:(MENotificationInboxStatus *)status {
    for (int i = (int) [self.notifications count] - 1; i >= 0; --i) {
        MENotification *notification = self.notifications[(NSUInteger) i];
        for (MENotification *currentNotification in status.notifications) {
            if ([currentNotification.id isEqual:notification.id]) {
                [self.notifications removeObjectAtIndex:(NSUInteger) i];
                break;
            }
        }
    }
}

- (void)respondWithError:(MEInboxResultErrorBlock)errorBlock error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock(error);
        }
    });
}

- (void)handleNoMeIdWithErrorBlock:(MEInboxResultErrorBlock)errorBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorBlock) {
            errorBlock([NSError errorWithCode:42 localizedDescription:@"MeId is not available."]);
        }
    });
}

@end