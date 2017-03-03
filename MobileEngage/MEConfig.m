//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEConfig.h"
#import "MEConfigBuilder.h"


@implementation MEConfig

+ (nonnull MEConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    MEConfigBuilder *builder = [MEConfigBuilder new];
    builderBlock(builder);

    NSParameterAssert(builder.applicationId);
    NSParameterAssert(builder.applicationSecret);

    return [[MEConfig alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(MEConfigBuilder *)builder {
    if (self = [super init]) {
        _applicationId = builder.applicationId;
        _applicationSecret = builder.applicationSecret;
    }

    return self;
}

@end