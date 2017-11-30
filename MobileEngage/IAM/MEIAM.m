//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAM.h"
#import "MEIAM+Private.h"
#import "MEIAMViewController.h"
#import "MEJSBridge.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAMProtocol.h"

@interface MEIAM () <MEIAMProtocol>

@property(nonatomic, weak) MEIAMViewController *meiamViewController;

@end

@implementation MEIAM

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)showMessage:(NSString *)html {
    dispatch_async(dispatch_get_main_queue(), ^{
        MEIAMJSCommandFactory *commandFactory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:self];
        MEJSBridge *jsBridge = [[MEJSBridge alloc] initWithJSCommandFactory:commandFactory];
        MEIAMViewController *viewController = [[MEIAMViewController alloc] initWithJSBridge:jsBridge];
        _meiamViewController = viewController;
        [_meiamViewController loadMessage:html
                        completionHandler:^{
                            [self.topViewController presentViewController:viewController
                                                                 animated:YES
                                                               completion:nil];
                        }];
    });
}

- (UIViewController *)rootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

- (UIViewController *)topViewController {
    return [self topViewControllerFrom:[self rootViewController]];
}

- (UIViewController *)topViewControllerFrom:(UIViewController *)currentViewController {
    UIViewController *result = currentViewController;
    if (currentViewController.presentedViewController) {
        result = [self topViewControllerFrom:currentViewController.presentedViewController];
    } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
        result = [self topViewControllerFrom:[((UINavigationController *) currentViewController) viewControllers].lastObject];
    } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
        result = [self topViewControllerFrom:[((UITabBarController *) currentViewController) selectedViewController]];
    }
    return result;
}

@end