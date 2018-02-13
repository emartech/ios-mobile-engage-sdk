//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"

@class MEIAMViewController;
@protocol MEInAppMessageHandler;

@protocol MEIAMProtocol <NSObject>

- (id <MEInAppMessageHandler>)messageHandler;
- (id <MEInAppTrackingProtocol>)inAppTracker;
- (NSString *)currentCampaignId;
- (void)closeInAppMessage;

@end