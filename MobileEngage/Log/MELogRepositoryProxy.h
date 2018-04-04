//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <CoreSDK/EMSLogRepositoryProtocol.h>
#import <CoreSDK/EMSLogHandlerProtocol.h>
#import <Foundation/Foundation.h>

@interface MELogRepositoryProxy: NSObject <EMSLogRepositoryProtocol>

- (instancetype)initWithLogRepository:(id<EMSLogRepositoryProtocol>)logRepository
                             handlers:(NSArray<id<EMSLogHandlerProtocol>> *)handlers;

@end