//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"

@interface MEExperimental : NSObject

+ (BOOL)isFeatureEnabled:(FlipperFeature)feature;
+ (void)enableFeature:(FlipperFeature)feature;

@end