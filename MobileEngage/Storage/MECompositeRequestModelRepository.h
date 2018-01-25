//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSRequestModelRepository.h"

@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;

@interface MECompositeRequestModelRepository : NSObject <EMSRequestModelRepositoryProtocol>

- (instancetype)initWithRequestModelRepository:(EMSRequestModelRepository *)requestModelRepository
                         buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository;

@end