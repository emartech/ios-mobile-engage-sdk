//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEIAMCommamndResultUtils.h"


@implementation MEIAMCommamndResultUtils

+ (NSDictionary<NSString *, NSObject *> *)createSuccessResultWith:(NSString *)jsCommandId {
    return @{@"success": @YES,
            @"id": jsCommandId
    };
}

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                   errorMessage:(NSString *)errorMessage {
    return @{@"success": @NO,
            @"id": jsCommandId,
            @"error": errorMessage
    };
}

+ (NSDictionary<NSString *, NSObject *> *)createMissingParameterErrorResultWith:(NSString *)jsCommandId
                                                               missingParameter:(NSString *)missingParameter {
    return [MEIAMCommamndResultUtils createErrorResultWith:jsCommandId
                                              errorMessage:[NSString stringWithFormat:@"Missing %@!", missingParameter]];
}

@end