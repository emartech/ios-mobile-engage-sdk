//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEExperimental.h"


@implementation MEExperimental
static NSMutableSet * _enabledFeatures;

+ (BOOL)isFeatureEnabled:(FlipperFeature)feature {
    return [_enabledFeatures containsObject:feature];
}

+ (void)enableFeature:(FlipperFeature)feature {
    if(_enabledFeatures == nil) {
        _enabledFeatures = [NSMutableSet new];
    }
    [_enabledFeatures addObject:feature];
}

+ (void)reset {
    _enabledFeatures = nil;
}

@end