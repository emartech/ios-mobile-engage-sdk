//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface MEIAMCommamndResultUtils : NSObject

+ (NSDictionary<NSString *, NSObject *> *)createSuccessResultWith:(NSString *)jsCommandId;

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                   errorMessage:(NSString *)errorMessage;

+ (NSDictionary<NSString *, NSObject *> *)createMissingParameterErrorResultWith:(NSString *)jsCommandId
                                                               missingParameter:(NSString *)missingParameter;

@end