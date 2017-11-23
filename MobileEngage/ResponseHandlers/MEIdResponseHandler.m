//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIdResponseHandler.h"

@implementation MEIdResponseHandler {
    MobileEngageInternal *_internal;
}

- (instancetype)initWithMobileEngageInternal:(MobileEngageInternal *)mobileEngageInternal {
    if (self = [super init]) {
        _internal = mobileEngageInternal;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return [self getMeId:response] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    _internal.meId = [self getMeId:response];
}

- (NSString *)getMeId:(EMSResponseModel *)response {
    return response.parsedBody[@"api_me_id"];
}


@end
