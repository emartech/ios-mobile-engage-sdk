//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInboxV2.h"

@class EMSRESTClient;

@interface MEInboxV2 (Private)

- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(MEConfig *)config
                    requestContext:(MERequestContext *)requestContext;

- (NSMutableArray *)notifications;

- (MERequestContext *)requestContext;

@end