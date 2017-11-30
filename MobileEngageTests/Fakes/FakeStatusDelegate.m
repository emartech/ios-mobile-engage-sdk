//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeStatusDelegate.h"
#import <XCTest/XCTest.h>

@implementation FakeStatusDelegate {
    XCTestExpectation *_nextExpectation;
}

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
        [_nextExpectation fulfill];
    }
}


- (void)waitForNextSuccess {
    _nextExpectation = [[XCTestExpectation alloc] initWithDescription:@"wait"];
    [XCTWaiter waitForExpectations:@[_nextExpectation] timeout:30.0];
}

@end