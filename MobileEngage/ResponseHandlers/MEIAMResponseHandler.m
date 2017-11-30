//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMResponseHandler.h"
#import "MobileEngage.h"
#import "MEIAM+Private.h"


@implementation MEIAMResponseHandler

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    id message = response.parsedBody[@"message"];
    return [message isKindOfClass:[NSDictionary class]] && message[@"html"] != nil;
}

- (void)handleResponse:(EMSResponseModel *)response {
    NSString *html = response.parsedBody[@"message"][@"html"];
    [[MobileEngage iam] showMessage:html];
}

@end