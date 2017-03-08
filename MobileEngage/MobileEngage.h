//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEConfig;
@protocol MobileEngageStatusDelegate;

@interface MobileEngage : NSObject

@property(class, nonatomic, weak) id <MobileEngageStatusDelegate> statusDelegate;

+ (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions;

+ (NSString *)appLogin;

+ (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue;

+ (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

+ (NSString *)trackCustomEvent:(nonnull NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes;

+ (NSString *)appLogout;

@end
