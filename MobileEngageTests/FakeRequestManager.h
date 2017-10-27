//
// Created by Peter Stojcsics on 2017. 10. 26..
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModel.h"


@interface FakeRequestManager : NSObject

@property (nonatomic, strong) NSMutableArray<EMSRequestModel *> *submittedModels;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *additionalHeaders;

- (void)submit:(EMSRequestModel *)model;

@end