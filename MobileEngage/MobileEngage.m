//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <CoreSDK/EMSRequestManager.h>
#import "MobileEngage.h"
#import "MEConfig.h"
#import "MobileEngageStatusDelegate.h"
#import "EMSRequestManager.h"
#import "NSString+EMSCore.h"

@implementation MobileEngage

static id <MobileEngageStatusDelegate> _statusDelegate;
static EMSRequestManager *_requestManager;

+ (void)setupWithRequestManager:(nonnull EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions {
    _requestManager = requestManager;

    NSDictionary<NSString *, NSString *> *additionalHeaders = @{
            @"Authorization": [NSString createBasicAuthWith:config.applicationId
                                                   password:config.applicationSecret]
    };
}

+ (void)setupWithConfig:(nonnull MEConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    [self setupWithRequestManager:[EMSRequestManager new]
                           config:config
                    launchOptions:launchOptions];
}

+ (void)appLogin {
}

+ (void)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                 contactFieldValue:(NSString *)contactFieldValue {
}

+ (void)appLogout {
}

+ (void)trackCustomEvent:(nonnull NSString *)eventName
         eventAttributes:(NSDictionary<NSString *, id> *)eventAttributes {
}

+ (void)setStatusDelegate:(id <MobileEngageStatusDelegate>)statusDelegate {
    _statusDelegate = statusDelegate;
}

+ (id <MobileEngageStatusDelegate>)statusDelegate {
    return _statusDelegate;
}


@end
