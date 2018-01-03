//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MEDisplayedIAM : NSObject

@property (nonatomic, strong) NSString *campaignId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithCampaignId:(NSString *)campaignId eventName:(NSString *)eventName timestamp:(NSDate *)timestamp;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToIam:(MEDisplayedIAM *)iam;

- (NSUInteger)hash;

- (NSString *)description;


@end