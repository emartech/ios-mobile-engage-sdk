//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MEInAppMessageHandler <NSObject>

- (void)handleApplicationEvent:(NSString *)eventName
                       payload:(nullable NSDictionary<NSString *, NSObject *> *)payload;

@end

NS_ASSUME_NONNULL_END