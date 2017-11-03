//
// Created by Peter Stojcsics on 2017. 10. 26..
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeRequestManager.h"


@implementation FakeRequestManager

- (instancetype)init {
    self = [super init];
    if(self) {
        _submittedModels = [NSMutableArray new];
    }
    return self;
}

- (void)submit:(EMSRequestModel *)model {
    [_submittedModels addObject:model];
}

@end