//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"

@class EMSRequestManager;

@interface MobileEngageInternal (Private)

- (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions;

@end