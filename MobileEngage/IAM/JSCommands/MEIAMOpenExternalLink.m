//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMOpenExternalLink.h"
#import <UIKit/UIKit.h>
#import "MEOsVersionUtils.h"
#import "MEIAMCommamndResultUtils.h"

#define kExternalLink @"url"

@implementation MEIAMOpenExternalLink

+ (NSString *)commandName {
    return @"openExternalLink";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    UIApplication *application = [UIApplication sharedApplication];
    NSString *externalLink = message[kExternalLink];
    NSURL *url = [NSURL URLWithString:externalLink];
    NSString *eventId = message[@"id"];
    if (url) {
        if ([application canOpenURL:url]) {
            if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
                resultBlock([self createResultWithJSCommandId:eventId
                                                      success:[application openURL:url]]);
            } else {
                [application openURL:url
                             options:nil
                   completionHandler:^(BOOL success) {
                       resultBlock([self createResultWithJSCommandId:eventId
                                                             success:success]);
                   }];
            }
        } else {
            resultBlock([MEIAMCommamndResultUtils createErrorResultWith:eventId
                                                           errorMessage:@"Can't open url!"]);
        }
    } else {
        resultBlock([MEIAMCommamndResultUtils createMissingParameterErrorResultWith:eventId
                                                                   missingParameter:@"url"]);
    }
}

- (NSDictionary<NSString *, NSObject *> *)createResultWithJSCommandId:(NSString *)jsCommandId
                                                              success:(BOOL)success {
    NSDictionary<NSString *, NSObject *> *result;
    if (success) {
        result = [MEIAMCommamndResultUtils createSuccessResultWith:jsCommandId];
    } else {
        result = [MEIAMCommamndResultUtils createErrorResultWith:jsCommandId
                                                    errorMessage:@"Opening url failed!"];
    }
    return result;
}

@end
