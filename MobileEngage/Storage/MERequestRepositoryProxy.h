//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreSDK/EMSRequestModelRepositoryProtocol.h>
#import <CoreSDK/EMSRequestModelRepository.h>

@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;
@class MEInApp;

@interface MERequestRepositoryProxy : NSObject <EMSRequestModelRepositoryProtocol>

@property(nonatomic, readonly) MEInApp *inApp;
@property(nonatomic, readonly) EMSRequestModelRepository *requestModelRepository;
@property(nonatomic, readonly) MEButtonClickRepository *clickRepository;
@property(nonatomic, readonly) MEDisplayedIAMRepository *displayedIAMRepository;

- (instancetype)initWithRequestModelRepository:(EMSRequestModelRepository *)requestModelRepository
                         buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                                         inApp:(MEInApp *)inApp;

@end