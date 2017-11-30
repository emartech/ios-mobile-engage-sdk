//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"


@class MobileEngageInternal;
@interface MEIdResponseHandler : AbstractResponseHandler

- (instancetype)initWithMobileEngageInternal:(MobileEngageInternal *)mobileEngageInternal;

@end
