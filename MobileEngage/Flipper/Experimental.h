//
// Created by Peter Stojcsics on 2017. 10. 12..
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlipperFeatures.h"

@interface Experimental : NSObject

+ (BOOL)isFeatureEnabled:(FlipperFeature)feature;
+ (void)enableFeature:(FlipperFeature)feature;

@end