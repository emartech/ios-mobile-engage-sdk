//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInApp.h"
#import "MobileEngage.h"
#import <UIKit/UIKit.h>
#import "MEInAppMessage.h"
#import "MEInAppTrackingProtocol.h"
#import "MELogRepository.h"

@interface MEInApp (Private)

@property(nonatomic, weak, nullable) id <MEInAppTrackingProtocol> inAppTracker;
@property(nonatomic, strong) MELogRepository *logRepository;

- (UIWindow *)iamWindow;

- (void)setIamWindow:(UIWindow *)window;

- (void)showMessage:(MEInAppMessage *)message;

@end