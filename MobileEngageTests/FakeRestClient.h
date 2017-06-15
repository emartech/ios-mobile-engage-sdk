//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClient.h"

typedef enum {
    ResultTypeSuccess,
    ResultTypeFailure
} ResultType;

@interface FakeRestClient : EMSRESTClient

- (instancetype)initWithResultType:(ResultType)resultType;

@end