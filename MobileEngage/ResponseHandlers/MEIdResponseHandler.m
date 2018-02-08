//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIdResponseHandler.h"
#import "MobileEngageInternal.h"

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
    return [self getMeId:response] && [self getMeIdSignature:response];
}

- (void)handleResponse:(EMSResponseModel *)response {
    _internal.meId = [self getMeId:response];
    _internal.meIdSignature = [self getMeIdSignature:response];
}

- (NSString *)getMeId:(EMSResponseModel *)response {
    NSString *result;
    id meId = response.parsedBody[@"api_me_id"];
    if ([meId isKindOfClass:[NSString class]]) {
        result = meId;
    } else if ([meId isKindOfClass:[NSNumber class]]) {
        result = [(NSNumber *)response.parsedBody[@"api_me_id"] stringValue];
    }
    return result;
}

- (NSString *)getMeIdSignature:(EMSResponseModel *)response {
    return response.parsedBody[@"me_id_signature"];
}

@end
