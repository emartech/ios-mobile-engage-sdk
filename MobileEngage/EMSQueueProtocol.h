//
// Copyright (c) 2017 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModel.h"

@protocol EMSQueueProtocol <NSObject>

- (void)push:(EMSRequestModel *)model;

- (void)pushFirst:(EMSRequestModel *)model;

- (EMSRequestModel *)pop;

@end