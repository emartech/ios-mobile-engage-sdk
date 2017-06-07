//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MENotification : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *customData;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *rootParams;
@property(nonatomic, strong) NSNumber *expirationTime;
@property(nonatomic, strong) NSDate *receivedAt;

@end