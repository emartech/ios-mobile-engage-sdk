//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEAppLoginParameters.h"

@protocol MobileEngageStatusDelegate;
@class MEConfig;

NS_ASSUME_NONNULL_BEGIN
@interface MobileEngageInternal : NSObject

@property(nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(nonatomic, strong) NSData *pushToken;
@property(nonatomic, strong, nullable) MEAppLoginParameters *lastAppLoginParameters;

- (void)setupWithConfig:(MEConfig *)config
          launchOptions:(nullable NSDictionary *)launchOptions;

- (NSString *)appLogin;

- (NSString *)appLoginWithContactFieldId:(nullable NSNumber *)contactFieldId
                       contactFieldValue:(nullable NSString *)contactFieldValue;

- (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (NSString *)trackCustomEvent:(NSString *)eventName
               eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

- (NSString *)appLogout;

@end

NS_ASSUME_NONNULL_END
