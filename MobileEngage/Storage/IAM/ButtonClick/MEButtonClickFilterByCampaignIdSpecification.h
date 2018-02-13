//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreSDK/EMSSQLSpecificationProtocol.h>

@interface MEButtonClickFilterByCampaignIdSpecification : NSObject <EMSSQLSpecificationProtocol>

@property (nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end
