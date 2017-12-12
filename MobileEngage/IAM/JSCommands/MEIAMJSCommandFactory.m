//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMProtocol.h"
#import "MEIAMTriggerAppEvent.h"

@implementation MEIAMJSCommandFactory

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meiam {
    if (self = [super init]) {
        _meiam = meiam;
    }
    return self;
}

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name {
    id <MEIAMJSCommandProtocol> command;
    if ([name isEqualToString:MEIAMRequestPushPermission.commandName]) {
        command = [MEIAMRequestPushPermission new];
    } else if ([name isEqualToString:MEIAMOpenExternalLink.commandName]) {
        command = [MEIAMOpenExternalLink new];
    } else if ([name isEqualToString:MEIAMClose.commandName]) {
        command = [[MEIAMClose alloc] initWithViewController:[self.meiam meiamViewController]];
    } else if ([name isEqualToString:MEIAMTriggerAppEvent.commandName]) {
        command = [[MEIAMTriggerAppEvent alloc] initWithInAppMessageHandler:[self.meiam messageHandler]];
    }
    return command;
}

@end