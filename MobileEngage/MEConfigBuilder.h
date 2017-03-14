//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfig;

NS_ASSUME_NONNULL_BEGIN
@interface MEConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationId;
@property(nonatomic, readonly) NSString *applicationSecret;

- (MEConfigBuilder *)setCredentialsWithApplicationId:(NSString *)applicationId
                                    applicationSecret:(NSString *)applicationSecret;

@end

NS_ASSUME_NONNULL_END