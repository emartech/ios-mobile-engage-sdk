//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSRequestModelRepository.h>
#import "MERequestModelRepositoryFactory.h"
#import "MEButtonClickRepository.h"
#import "MERequestRepositoryProxy.h"
#import "MEDisplayedIAMRepository.h"
#import "MEInApp.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"

@implementation MERequestModelRepositoryFactory

- (instancetype)initWithInApp:(MEInApp *)inApp {
    NSParameterAssert(inApp);
    if (self = [super init]) {
        _inApp = inApp;
    }
    return self;
}

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing {
    if (batchProcessing) {
        return [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]]
                                                          buttonClickRepository:[[MEButtonClickRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                         displayedIAMRepository:[[MEDisplayedIAMRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                                          inApp:self.inApp];
    }
    return [[EMSRequestModelRepository alloc] initWithDbHelper:[[EMSSQLiteHelper alloc] initWithDefaultDatabase]];
}

@end