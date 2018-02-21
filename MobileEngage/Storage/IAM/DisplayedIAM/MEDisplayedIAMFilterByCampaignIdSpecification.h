//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

@interface MEDisplayedIAMFilterByCampaignIdSpecification : NSObject <EMSSQLSpecificationProtocol>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;


@end
