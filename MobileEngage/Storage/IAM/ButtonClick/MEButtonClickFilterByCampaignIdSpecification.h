//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MESQLSpecification.h"

@interface MEButtonClickFilterByCampaignIdSpecification : NSObject <MESQLSpecification>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end
