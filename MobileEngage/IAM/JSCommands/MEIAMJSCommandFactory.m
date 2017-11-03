//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"

@implementation MEIAMJSCommandFactory

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name {
    id <MEIAMJSCommandProtocol> command;
    if ([name isEqualToString:MEIAMRequestPushPermission.commandName]) {
        command = [MEIAMRequestPushPermission new];
    } else if ([name isEqualToString:MEIAMOpenExternalLink.commandName]) {
        command = [MEIAMOpenExternalLink new];
    }
    return command;
}

@end