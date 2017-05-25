//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+MobileEngage.h"

#define MobileEngageSIDKey @"sid"
#define PushwooshMessageCustomDataKey @"u"

@implementation NSDictionary (MobileEngage)

- (nullable NSString *)messageId {
    id customData = self[PushwooshMessageCustomDataKey];

    if([customData isKindOfClass:[NSString class]]){
        NSString *sid;

        NSData *data = [customData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSDictionary<NSString *, id> *customDataDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:nil];
            sid = customDataDict[MobileEngageSIDKey];
        }
        return sid;
        
    }else if([customData isKindOfClass:[NSDictionary<NSString*, NSString*> class]]){
        return customData[MobileEngageSIDKey];
    }
    return nil;
}


@end
