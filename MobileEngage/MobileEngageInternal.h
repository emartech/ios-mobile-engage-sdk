//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEAppLoginParameters.h"
#import "MENotification.h"
#import "EMSRequestManager.h"
#import "EMSTimestampProvider.h"

@protocol MobileEngageStatusDelegate;
@class MEConfig;

#define kSuiteName @"com.emarsys.mobileengage"
#define kLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"

typedef void (^MESuccessBlock)(NSString *requestId, EMSResponseModel *);
typedef void (^MEErrorBlock)(NSString *requestId, NSError *error);

NS_ASSUME_NONNULL_BEGIN
@interface MobileEngageInternal : NSObject

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MESuccessBlock successBlock;
@property(nonatomic, strong) MEErrorBlock errorBlock;

@property(nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(nonatomic, strong) NSData *pushToken;
@property(nonatomic, strong, nullable) MEAppLoginParameters *lastAppLoginParameters;
@property(nonatomic, strong, nullable) NSString *meId;
@property(nonatomic, strong, nullable) EMSTimestampProvider *timestampProvider;

- (void)setupWithConfig:(MEConfig *)config
          launchOptions:(nullable NSDictionary *)launchOptions;

- (NSString *)appLogin;

- (NSString *)appLoginWithContactFieldId:(nullable NSNumber *)contactFieldId
                       contactFieldValue:(nullable NSString *)contactFieldValue;

- (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

- (NSString *)trackMessageOpenWithInboxMessage:(MENotification *)inboxMessage;

- (NSString *)trackCustomEvent:(NSString *)eventName
               eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

- (NSString *)appLogout;

@end

NS_ASSUME_NONNULL_END
