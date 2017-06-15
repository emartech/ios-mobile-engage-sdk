//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <CoreSDK/NSError+EMSCore.h>
#import "MEInbox.h"
#import "MEInbox+Private.h"
#import "EMSRequestModelBuilder.h"
#import "EMSResponseModel.h"
#import "MEDefaultHeaders.h"
#import "MEConfig.h"
#import "EMSDeviceInfo.h"
#import "MEAppLoginParameters.h"
#import "MEInboxParser.h"

@interface MEInbox ()

@property(nonatomic, strong) EMSRESTClient *restClient;
@property(nonatomic, strong) MEConfig *config;

@end

@implementation MEInbox

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
    }
    return self;
}

- (void)fetchNotificationsWithResultBlock:(MEInboxResultBlock)resultBlock
                               errorBlock:(MEInboxResultErrorBlock)errorBlock {
    NSParameterAssert(resultBlock);
    if (self.appLoginParameters && self.appLoginParameters.contactFieldId && self.appLoginParameters.contactFieldValue) {
        EMSRequestModel *request = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            NSDictionary *headers = [self createNotificationsFetchingHeaders];
            [[[builder setMethod:HTTPMethodGET] setHeaders:headers] setUrl:@"https://me-inbox.eservice.emarsys.net/api/notifications"];
        }];
        [_restClient executeTaskWithRequestModel:request
                                    successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:nil];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            resultBlock([[MEInboxParser new] parseNotificationInboxStatus:payload]);
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

- (NSDictionary<NSString *, NSString *> *)createNotificationsFetchingHeaders {
    NSDictionary *defaultHeaders = [MEDefaultHeaders additionalHeadersWithConfig:self.config];
    NSMutableDictionary *mutableFetchingHeaders = [NSMutableDictionary dictionaryWithDictionary:defaultHeaders];
    mutableFetchingHeaders[@"x-ems-me-hardware-id"] = [EMSDeviceInfo hardwareId];
    mutableFetchingHeaders[@"x-ems-me-application-code"] = self.config.applicationCode;
    mutableFetchingHeaders[@"x-ems-me-contact-field-id"] = [NSString stringWithFormat:@"%@", self.appLoginParameters.contactFieldId];
    mutableFetchingHeaders[@"x-ems-me-contact-field-value"] = self.appLoginParameters.contactFieldValue;
    return [NSDictionary dictionaryWithDictionary:mutableFetchingHeaders];
}

@end