//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfig;

NS_ASSUME_NONNULL_BEGIN
@interface MEConfigBuilder : NSObject

@property(nonatomic, readonly) NSString *applicationCode;
@property(nonatomic, readonly) NSString *applicationPassword;

- (MEConfigBuilder *)setCredentialsWithApplicationCode:(NSString *)applicationCode
                                   applicationPassword:(NSString *)applicationPassword;

@end

NS_ASSUME_NONNULL_END