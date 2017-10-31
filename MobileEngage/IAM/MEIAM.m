//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAM.h"
#import "MEIAM+Private.h"

@interface MEIAM ()

@end

@implementation MEIAM

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
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