//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInbox.h"

@interface MEInbox (Private)

- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(MEConfig *)config;

- (NSMutableSet *)notifications;

@end