//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSInMemoryQueue.h"


@implementation EMSInMemoryQueue {
    NSMutableArray *_data;
}

- (id)init {
    self = [super init];

    if (self) {
        _data = [NSMutableArray new];
    }

    return self;
}

- (void)push:(EMSRequestModel *)model {
    [_data addObject:model];
}

- (void)pushFirst:(EMSRequestModel *)model {
    [_data insertObject:model atIndex:0];
}

- (EMSRequestModel *)pop {
    EMSRequestModel *firstModel = [_data firstObject];
    [_data removeObject:firstModel];
    return firstModel;
}

@end