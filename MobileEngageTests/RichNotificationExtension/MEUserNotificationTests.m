#import "Kiwi.h"
#import "MEUserNotification.h"
#import <UserNotifications/UNNotification.h>
#import <UserNotifications/UNNotificationResponse.h>

SPEC_BEGIN(MEUserNotificationTests)

        describe(@"userNotificationCenter:willPresentNotification:withCompletionHandler:", ^{

                it(@"should call the injected delegate's userNotificationCenter:willPresentNotification:withCompletionHandler: method", ^{
                    id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                    UNUserNotificationCenter *mockCenter = [UNUserNotificationCenter mock];
                    UNNotification *mockNotification = [UNNotification mock];
                    void (^ const completionHandler)(UNNotificationPresentationOptions)=^(UNNotificationPresentationOptions options) {};

                    [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:) withArguments:mockCenter, mockNotification, completionHandler];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.delegate = userNotificationCenterDelegate;

                    [userNotification userNotificationCenter:mockCenter
                             willPresentNotification:mockNotification
                               withCompletionHandler:completionHandler];
                });
                
        });

        describe(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", ^{

                it(@"should call the injected delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: method", ^{
                    id userNotificationCenterDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                    UNUserNotificationCenter *center = [UNUserNotificationCenter mock];
                    UNNotificationResponse *notificationResponse = [UNNotificationResponse mock];
                    void (^ const completionHandler)()=^{};

                    [[userNotificationCenterDelegate should] receive:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) withArguments:center, notificationResponse, completionHandler];

                    MEUserNotification *userNotification = [MEUserNotification new];
                    userNotification.delegate = userNotificationCenterDelegate;

                    [userNotification userNotificationCenter:center
                      didReceiveNotificationResponse:notificationResponse
                               withCompletionHandler:completionHandler];
                });
        });

SPEC_END