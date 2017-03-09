//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeRequestManager.h"
#import "EMSRequestModel.h"

@implementation FakeRequestManager

- (void)submit:(EMSRequestModel *)model
  successBlock:(CoreSuccessBlock)successBlock
    errorBlock:(CoreErrorBlock)errorBlock {
    if (self.responseType == ResponseTypeSuccess) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            successBlock(model.requestId);
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"com.emarsys.mobileengage"
                                                 code:1
                                             userInfo:@{NSLocalizedDescriptionKey: @"Errorka"}];
            errorBlock(model.requestId, error);
        });
    }
}

@end