//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@interface MEIAMJSCommandFactory : NSObject

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name;

@end