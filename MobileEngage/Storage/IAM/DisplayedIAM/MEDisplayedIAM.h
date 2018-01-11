//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MEDisplayedIAM : NSObject

@property (nonatomic, assign) long campaignId;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithCampaignId:(long)campaignId timestamp:(NSDate *)timestamp;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToIam:(MEDisplayedIAM *)iam;

- (NSUInteger)hash;

@end