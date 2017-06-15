//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSAuthentication.h>
#import "MEDefaultHeaders.h"
#import "MEConfig.h"
#import "MobileEngageVersion.h"

@implementation MEDefaultHeaders

+ (NSDictionary *)additionalHeadersWithConfig:(MEConfig *)config {
    return @{
            @"Authorization": [EMSAuthentication createBasicAuthWithUsername:config.applicationCode
                                                                    password:config.applicationPassword],
            @"Content-Type": @"application/json",
            @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION
    };
}

@end