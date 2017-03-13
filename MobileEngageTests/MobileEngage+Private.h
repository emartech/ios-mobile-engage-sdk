//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngage.h"

@class MobileEngageInternal;

@interface MobileEngage (Private)

+ (void)setupWithMobileEngageInternal:(MobileEngageInternal *)mobileEngageInternal
                               config:(MEConfig *)config
                        launchOptions:(NSDictionary *)launchOptions;

@end