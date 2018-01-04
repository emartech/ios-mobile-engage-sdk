//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MEDisplayedIAM : NSObject

@property (nonatomic, strong) NSString *campaignId;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithCampaignId:(NSString *)campaignId timestamp:(NSDate *)timestamp;

@end