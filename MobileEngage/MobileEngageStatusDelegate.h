//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MobileEngageStatusDelegate <NSObject>

@optional

- (void)mobileEngageErrorHappenedWithEventId:(NSString *)eventId
                                       error:(NSError *)error;

- (void)mobileEngageLogReceivedWithEventId:(NSString *)eventId
                                       log:(NSString *)log;
@end