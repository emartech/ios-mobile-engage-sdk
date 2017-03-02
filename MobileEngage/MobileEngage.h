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

+ (void)appLogin;

+ (void)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                 contactFieldValue:(NSString *)contactFieldValue;

+ (void)appLogout;

+ (void)trackCustomEvent:(nonnull NSString *)eventName
         eventAttributes:(NSDictionary<NSString *, id> *)eventAttributes;

@end
