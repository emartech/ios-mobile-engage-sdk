//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+MobileEngage.h"

#define MobileEngageSIDKey @"sid"
#define PushwooshMessageCustomDataKey @"u"

@implementation NSDictionary (MobileEngage)

- (NSString *)messageId {
    NSString *sid;
    NSString *customData = self[PushwooshMessageCustomDataKey];
    NSData *data = [customData dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary<NSString *, id> *customDataDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                       options:NSJSONReadingAllowFragments
                                                                                         error:nil];
        sid = customDataDict[MobileEngageSIDKey];
    }
    return sid;
}

@end