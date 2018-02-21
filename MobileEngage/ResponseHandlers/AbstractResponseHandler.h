//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

@interface AbstractResponseHandler : NSObject

- (void)processResponse:(EMSResponseModel *)response;

@end
