//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@class MEIAMViewController;

@interface MEIAMClose : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithViewController:(MEIAMViewController *)viewController;

@end