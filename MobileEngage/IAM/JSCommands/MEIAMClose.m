//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMClose.h"
#import "MEIAMViewController.h"

@interface MEIAMClose ()

@property(weak, nonatomic) MEIAMViewController *viewController;

@end

@implementation MEIAMClose

+ (NSString *)commandName {
    return @"close";
}

- (instancetype)initWithViewController:(MEIAMViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    [self.viewController dismissViewControllerAnimated:NO
                                            completion:nil];
}

@end