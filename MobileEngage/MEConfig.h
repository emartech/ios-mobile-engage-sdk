//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfigBuilder;

@interface MEConfig : NSObject

@property(nonatomic, readonly) NSString *applicationId;
@property(nonatomic, readonly) NSString *applicationSecret;

typedef void(^MEConfigBuilderBlock)(MEConfigBuilder * _Nonnull builder);

+ (nonnull MEConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock;


@end