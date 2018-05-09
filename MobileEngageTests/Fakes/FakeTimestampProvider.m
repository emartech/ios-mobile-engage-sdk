//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "FakeTimestampProvider.h"


@implementation FakeTimestampProvider

- (NSDate *)provideTimestamp {
    return self.currentDate;
}

@end