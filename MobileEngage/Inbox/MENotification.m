//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MENotification.h"

@implementation MENotification {

}
- (instancetype)initWithNotificationDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _id = dictionary[@"id"];
        _sid = dictionary[@"sid"];
        _title = dictionary[@"title"];
        _customData = dictionary[@"custom_data"];
        _rootParams = dictionary[@"root_params"];
        _expirationTime = dictionary[@"expiration_time"];
        _receivedAt = [NSDate dateWithTimeIntervalSince1970:[(dictionary[@"received_at"]) doubleValue] / 1000];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToNotification:other];
}

- (BOOL)isEqualToNotification:(MENotification *)notification {
    if (self == notification)
        return YES;
    if (notification == nil)
        return NO;
    if (self.id != notification.id && ![self.id isEqualToString:notification.id])
        return NO;
    if (self.sid != notification.sid && ![self.sid isEqualToString:notification.sid])
        return NO;
    if (self.title != notification.title && ![self.title isEqualToString:notification.title])
        return NO;
    if (self.customData != notification.customData && ![self.customData isEqualToDictionary:notification.customData])
        return NO;
    if (self.rootParams != notification.rootParams && ![self.rootParams isEqualToDictionary:notification.rootParams])
        return NO;
    if (self.expirationTime != notification.expirationTime && ![self.expirationTime isEqualToNumber:notification.expirationTime])
        return NO;
    if (self.receivedAt != notification.receivedAt && [self.receivedAt timeIntervalSince1970] != [notification.receivedAt timeIntervalSince1970])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.sid hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.customData hash];
    hash = hash * 31u + [self.rootParams hash];
    hash = hash * 31u + [self.expirationTime hash];
    hash = hash * 31u + [self.receivedAt hash];
    return hash;
}


@end