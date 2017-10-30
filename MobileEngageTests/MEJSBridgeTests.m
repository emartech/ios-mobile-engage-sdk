#import "Kiwi.h"
#import "MEJSBridge.h"
#import <UserNotifications/UserNotifications.h>

MEJSBridge *_meJsBridge;
UIApplication *_applicationMock;

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

SPEC_BEGIN(MEJSBridgeTests)

    beforeEach(^{
        _meJsBridge = [MEJSBridge new];
        _applicationMock = [UIApplication mock];
        [[UIApplication should] receive:@selector(sharedApplication) andReturn:_applicationMock];
    });

    describe(@"requestPushPermission", ^{

        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application under iOS 10", ^{
                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[_applicationMock should] receive:@selector(registerUserNotificationSettings:) withArguments:any()];
                KWCaptureSpy *spy = [_applicationMock captureArgument:@selector(registerUserNotificationSettings:)
                                                              atIndex:0];

                [_meJsBridge requestPushPermission];
                UIUserNotificationSettings *notificationSettings = spy.argument;
                UIUserNotificationType type = notificationSettings.types;
                [[theValue(type) should] equal:theValue(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)];

            });
        }

        if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            it(@"should call registration process on application when os version is greater or equal then iOS 10", ^{
                UNUserNotificationCenter *userNotificationCenterMock = [UNUserNotificationCenter mock];
                [[UNUserNotificationCenter should] receive:@selector(currentNotificationCenter) andReturn:userNotificationCenterMock];

                [[_applicationMock should] receive:@selector(registerForRemoteNotifications)];
                [[userNotificationCenterMock should] receive:@selector(requestAuthorizationWithOptions:completionHandler:) withArguments:any(), any()];

                KWCaptureSpy *spy = [userNotificationCenterMock captureArgument:@selector(requestAuthorizationWithOptions:completionHandler:)
                                                                        atIndex:0];
                [_meJsBridge requestPushPermission];

                [[spy.argument should] equal:theValue(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)];
            });
        }

    });

SPEC_END