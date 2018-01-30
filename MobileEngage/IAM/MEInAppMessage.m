//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEInAppMessage.h"

@implementation MEInAppMessage

- (instancetype)initWithResponseParsedBody:(NSDictionary *)parsedBody; {
    if (self = [super init]) {
        _html = parsedBody[@"message"][@"html"];
        _campaignId = parsedBody[@"message"][@"id"];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToMessage:other];
}

- (BOOL)isEqualToMessage:(MEInAppMessage *)message {
    if (self == message)
        return YES;
    if (message == nil)
        return NO;
    if (self.campaignId != message.campaignId && ![self.campaignId isEqualToString:message.campaignId])
        return NO;
    if (self.html != message.html && ![self.html isEqualToString:message.html])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.campaignId hash];
    hash = hash * 31u + [self.html hash];
    return hash;
}


@end
