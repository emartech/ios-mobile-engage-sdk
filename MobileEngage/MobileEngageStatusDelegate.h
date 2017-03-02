//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MobileEngageStatusDelegate <NSObject>

@optional
- (void)mobileEngageErrorHappened:(NSError *)error;

- (void)mobileEngageLogReceived:(NSString *)log;

@end