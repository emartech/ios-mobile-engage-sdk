//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

@class MEIAMViewController;
@protocol MEEventHandler;

@protocol MEIAMProtocol <NSObject>

- (id <MEEventHandler>)eventHandler;
- (id <MEInAppTrackingProtocol>)inAppTracker;
- (NSString *)currentCampaignId;
- (void)closeInAppMessage;

@end