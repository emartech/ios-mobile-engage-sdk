//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEInApp.h"
#import "MEInApp+Private.h"
#import "MEIAMViewController.h"
#import "MEJSBridge.h"
#import "MEIAMJSCommandFactory.h"
#import "MobileEngage+Private.h"
#import "MEDisplayedIAMRepository.h"

@interface MEInApp () <MEIAMProtocol>

@property(nonatomic, weak) NSString *currentCampaignId;
@property(nonatomic, strong) UIWindow *iamWindow;
@property(nonatomic, weak, nullable) id <MEInAppTrackingProtocol> inAppTracker;
@property(nonatomic, assign) BOOL isPaused;

@end

@implementation MEInApp

#pragma mark - Public methods

- (void)pause {
    _isPaused = YES;
}

- (void)resume {
    _isPaused = NO;
}


- (void)showMessage:(MEInAppMessage *)message {
    self.currentCampaignId = message.campaignId;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.iamWindow && !self.isPaused) {
            self.iamWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            MEIAMJSCommandFactory *commandFactory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:self];
            MEJSBridge *jsBridge = [[MEJSBridge alloc] initWithJSCommandFactory:commandFactory];
            MEIAMViewController *meiamViewController = [[MEIAMViewController alloc] initWithJSBridge:jsBridge];
            __weak typeof(self) weakSelf = self;
            [meiamViewController loadMessage:message.html
                           completionHandler:^{
                               [weakSelf displayInAppViewController:message
                                                     viewController:meiamViewController];
                           }];
        }
    });
}

#pragma mark - Private methods

- (void)displayInAppViewController:(MEInAppMessage *)message
                    viewController:(MEIAMViewController *)meiamViewController {
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view.backgroundColor = [UIColor clearColor];
    self.iamWindow.backgroundColor = [UIColor clearColor];
    self.iamWindow.rootViewController = rootViewController;
    self.iamWindow.windowLevel = UIWindowLevelAlert;
    [self.iamWindow makeKeyAndVisible];

    __weak typeof(self) weakSelf = self;
    [rootViewController presentViewController:meiamViewController
                                     animated:YES
                                   completion:^{
                                       [weakSelf trackIAMDisplay:message];
                                   }];
}

- (void)trackIAMDisplay:(MEInAppMessage *)message {
    MEDisplayedIAMRepository *repository = [[MEDisplayedIAMRepository alloc] initWithDbHelper:[MobileEngage dbHelper]];
    [repository add:[[MEDisplayedIAM alloc] initWithCampaignId:message.campaignId timestamp:[NSDate new]]];

    [self.inAppTracker trackInAppDisplay:message.campaignId];
}

- (void)closeInAppMessage {
    __weak typeof(self) weakSelf = self;
    [self.iamWindow.rootViewController dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                                                              weakSelf.iamWindow = nil;
                                                          }];
}


@end