//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInApp.h"
#import "MobileEngage.h"
#import <UIKit/UIKit.h>

@interface MEInApp (Private)

- (instancetype)init;

- (UIViewController *)rootViewController;

- (UIViewController *)topViewController;

- (UIViewController *)topViewControllerFrom:(UIViewController *)currentViewController;

- (void)showMessage:(NSString *)html;

@end