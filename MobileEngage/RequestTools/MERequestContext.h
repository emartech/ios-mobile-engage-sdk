//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSuiteName @"com.emarsys.mobileengage"
#define kLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"

@interface MERequestContext : NSObject

@property(nonatomic, strong, nullable) NSDictionary *lastAppLoginPayload;
@property(nonatomic, strong, nullable) NSString *meId;
@property(nonatomic, strong, nullable) NSString *meIdSignature;

@end