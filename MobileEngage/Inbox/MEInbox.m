//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSError+EMSCore.h"
#import "MEInbox.h"
#import "EMSRequestModelBuilder.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "MEConfig.h"
#import "EMSDeviceInfo.h"
#import "MEAppLoginParameters.h"
#import "MEInboxParser.h"
#import "EMSRESTClient.h"

@interface MEInbox ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) MEConfig *config;

@property(nonatomic, strong) NSMutableArray *notifications;

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders;

- (MENotificationInboxStatus *)mergedStatusWithStatus:(MENotificationInboxStatus *)status;

- (void)invalidateCachedNotifications:(MENotificationInboxStatus *)status;

@end

@implementation MEInbox

#pragma mark - Init

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
        _notifications = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public methods

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
    NSParameterAssert(resultBlock);
    if (self.appLoginParameters && self.appLoginParameters.contactFieldId && self.appLoginParameters.contactFieldValue) {
        EMSRequestModel *request = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            NSDictionary *headers = [self createNotificationsFetchingHeaders];
            [[[builder setMethod:HTTPMethodGET] setHeaders:headers] setUrl:@"https://me-inbox.eservice.emarsys.net/api/notifications"];
        }];
        __weak typeof(self) weakSelf = self;
        [_restClient executeTaskWithRequestModel:request
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:nil];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            MENotificationInboxStatus *status = [[MEInboxParser new] parseNotificationInboxStatus:payload];
                                            resultBlock([weakSelf mergedStatusWithStatus:status]);
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
                             localizedDescription:@"Login parameters are not available."]);
            }
        });
    }
}

- (void)resetBadgeCount {
    [self resetBadgeCountWithSuccessBlock:nil errorBlock:nil];
}

- (void)resetBadgeCountWithSuccessBlock:(MEInboxSuccessBlock)successBlock
                             errorBlock:(MEInboxResultErrorBlock)errorBlock {
    if (self.appLoginParameters && self.appLoginParameters.contactFieldId && self.appLoginParameters.contactFieldValue) {
        EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://me-inbox.eservice.emarsys.net/api/reset-badge-count"];
            [builder setMethod:HTTPMethodPOST];
            [builder setHeaders:[self createNotificationsFetchingHeaders]];
        }];
        [_restClient executeTaskWithRequestModel:model
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (successBlock) {
                                                successBlock();
                                            }
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
                             localizedDescription:@"Login parameters are not available."]);
            }
        });
    }
}


- (void)addNotification:(MENotification *)notification {
    [self.notifications insertObject:notification
                             atIndex:0];
}

#pragma mark - Private methods

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", self.appLoginParameters.contactFieldId];
    mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = self.appLoginParameters.contactFieldValue;
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

- (MENotificationInboxStatus *)mergedStatusWithStatus:(MENotificationInboxStatus *)status {
    [self invalidateCachedNotifications:status];

    NSMutableArray *notifications = [NSMutableArray new];
    [notifications addObjectsFromArray:self.notifications];
    [notifications addObjectsFromArray:status.notifications];

    MENotificationInboxStatus *result = [MENotificationInboxStatus new];
    result.badgeCount = status.badgeCount;
    result.notifications = [NSArray arrayWithArray:notifications];
    return result;
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

@end
