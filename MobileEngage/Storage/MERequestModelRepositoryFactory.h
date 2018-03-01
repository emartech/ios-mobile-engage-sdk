//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSRequestModelRepositoryProtocol;
@class MEInApp;

@interface MERequestModelRepositoryFactory : NSObject

@property (nonatomic, readonly) MEInApp *inApp;

- (instancetype)initWithInApp:(MEInApp *)inApp;

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing;

@end