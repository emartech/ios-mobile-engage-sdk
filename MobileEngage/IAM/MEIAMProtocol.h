//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEIAMViewController;
@protocol MEInAppMessageHandler;

@protocol MEIAMProtocol <NSObject>

- (id <MEInAppMessageHandler>)messageHandler;
- (NSString *)currentCampaignId;
- (void)closeInAppMessage;

@end