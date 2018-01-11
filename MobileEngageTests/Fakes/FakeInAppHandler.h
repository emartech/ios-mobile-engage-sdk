//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppMessageHandler.h"

typedef void (^MainThreadCheckerBlock)(BOOL mainThread);

@interface FakeInAppHandler : NSObject<MEInAppMessageHandler>

@property (nonatomic, strong) MainThreadCheckerBlock mainThreadCheckerBlock;

- (instancetype)initWithMainThreadCheckerBlock:(MainThreadCheckerBlock)mainThreadCheckerBlock;

@end