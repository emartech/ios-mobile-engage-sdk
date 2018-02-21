//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;

@interface MERequestRepositoryProxy : NSObject <EMSRequestModelRepositoryProtocol>

- (instancetype)initWithRequestModelRepository:(EMSRequestModelRepository *)requestModelRepository
                         buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository;

@end
