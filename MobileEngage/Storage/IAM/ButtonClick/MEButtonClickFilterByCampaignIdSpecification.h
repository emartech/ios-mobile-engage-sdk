//
//  Copyright © 2018 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

@interface MEButtonClickFilterByCampaignIdSpecification : NSObject <EMSSQLSpecificationProtocol>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end
