//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEConfigBuilder.h"
#import "MEConfig.h"

@implementation MEConfigBuilder

- (MEConfigBuilder *)setCredentialsWithApplicationId:(NSString *)applicationId
                                    applicationSecret:(NSString *)applicationSecret {
    _applicationId = applicationId;
    _applicationSecret = applicationSecret;
    return self;
}

@end