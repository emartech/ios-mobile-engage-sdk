//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAM.h"
#import "MobileEngage.h"
#import <UIKit/UIKit.h>

@interface MEIAM (Private)

- (instancetype)init;

- (UIViewController *)rootViewController;

- (UIViewController *)topViewController;

- (UIViewController *)topViewControllerFrom:(UIViewController *)currentViewController;

@end