//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfig;

@interface MEConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationId;
@property(nonatomic, readonly) NSString *applicationSecret;

- (MEConfigBuilder *)setCredentialsWithApplicationId:(NSString *)applicationId
                                    applicationSecret:(NSString *)applicationSecret;

@end