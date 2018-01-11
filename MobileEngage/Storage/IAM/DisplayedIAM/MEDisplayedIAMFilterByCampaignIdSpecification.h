//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MESQLSpecification.h"

@interface MEDisplayedIAMFilterByCampaignIdSpecification : NSObject <MESQLSpecification>

@property (nonatomic, readonly) long campaignId;

- (instancetype)initWithCampaignId:(long)campaignId;


@end