//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"
#import "MEButtonClickRepository.h"

@interface MEIAMButtonClicked : NSObject <MEIAMJSCommandProtocol>

@property(nonatomic, readonly) NSString *campaignId;
@property(nonatomic, readonly) MEButtonClickRepository *repository;

- (instancetype)initWithCampaignId:(NSString *)campaignId
                        repository:(MEButtonClickRepository *)repository;

@end
