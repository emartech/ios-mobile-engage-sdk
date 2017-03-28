//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeStatusDelegate.h"

@implementation FakeStatusDelegate

- (void)mobileEngageErrorHappenedWithEventId:(NSString *)eventId
                                       error:(NSError *)error {
    if ([NSThread isMainThread]) {
        self.errorCount++;
    }

    if (self.printErrors) {
        NSLog(@"%@", error);
    }
}

- (void)mobileEngageLogReceivedWithEventId:(NSString *)eventId
                                       log:(NSString *)log {
    if ([NSThread isMainThread]) {
        self.successCount++;
    }
}

@end