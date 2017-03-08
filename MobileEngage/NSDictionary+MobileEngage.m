//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+MobileEngage.h"

#define MobileEngageSIDKey @"sid"
#define PushwooshMessageCustomDataKey @"u"

@implementation NSDictionary (MobileEngage)

+ (NSString *)messageIdFromUserInfo:(NSDictionary *)userInfo {
    NSString *customData = userInfo[PushwooshMessageCustomDataKey];
    NSString *sid;
    if (customData) {
        NSData *data = [customData dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSDictionary<NSString *, id> *customDataDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:nil];
            if (customDataDict) {
                sid = customDataDict[MobileEngageSIDKey];
            }
        }
    }
    return sid;
}

@end