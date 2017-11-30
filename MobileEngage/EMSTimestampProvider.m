//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSTimestampProvider.h"


@implementation EMSTimestampProvider

- (NSNumber *)currentTimeStamp {
    return @((NSUInteger) (1000 * [[NSDate date] timeIntervalSince1970]));
}

@end