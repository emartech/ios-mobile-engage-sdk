//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MERequestContext.h"


@implementation MERequestContext

- (instancetype)init {
    if (self = [super init]) {
        _lastAppLoginPayload = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] dictionaryForKey:kLastAppLoginPayload];
        _meId = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] stringForKey:kMEID];
        _meIdSignature = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] stringForKey:kMEID_SIGNATURE];
    }
    return self;
}

- (void)setLastAppLoginPayload:(NSDictionary *)lastAppLoginPayload {
    _lastAppLoginPayload = lastAppLoginPayload;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:lastAppLoginPayload
                     forKey:kLastAppLoginPayload];
    [userDefaults synchronize];
}

- (void)setMeId:(NSString *)meId {
    _meId = meId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:meId
                     forKey:kMEID];
    [userDefaults synchronize];
}

- (void)setMeIdSignature:(NSString *)meIdSignature {
    _meIdSignature = meIdSignature;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:meIdSignature
                     forKey:kMEID_SIGNATURE];
    [userDefaults synchronize];
}

@end