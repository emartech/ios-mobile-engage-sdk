//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileEngageStatusDelegate.h"

@interface FakeStatusDelegate : NSObject <MobileEngageStatusDelegate>

@property(nonatomic, assign) int successCount;
@property(nonatomic, assign) int errorCount;
@property(nonatomic, assign) BOOL printErrors;

@end