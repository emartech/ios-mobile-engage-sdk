//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngage.h"

@class EMSRequestManager;

@interface MobileEngage(Private)

+ (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions;

@end