//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"

@class EMSRequestManager;

NS_ASSUME_NONNULL_BEGIN
@interface MobileEngageInternal (Private)

- (void)setupWithRequestManager:(EMSRequestManager *)requestManager
                         config:(MEConfig *)config
                  launchOptions:(nullable NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END