#import "Kiwi.h"
#import "MEIAM.h"
#import "MEIAM+Private.h"

MEIAM *iam;

SPEC_BEGIN(MEIAMTests)

    beforeEach(^{
        iam = [[MEIAM alloc] init];
    });
//
//    afterEach(^{
//        for (UIViewController *viewController in [[iam rootViewController] childViewControllers]) {
//            [viewController removeFromParentViewController];
//        }
//    });

    describe(@"rootViewController", ^{

        it(@"should not be nil", ^{
            UIViewController *rootViewController = [iam rootViewController];
            [[rootViewController shouldNot] beNil];
        });

    });

    describe(@"topViewController", ^{

        it(@"should not be nil", ^{
            UIViewController *topViewController = [iam topViewController];
            [[topViewController shouldNot] beNil];
        });

        it(@"should return rootViewController, when there is no more presented ViewController", ^{
            UIViewController *topViewController = [iam topViewController];
            [[topViewController should] equal:[iam rootViewController]];
        });

        it(@"should return the presentedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *presentedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:presentedViewController];
            [presentedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:presentedViewController];
        });

        it(@"should return the nestedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *presentedViewController = [UIViewController mock];
            UIViewController *nestedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:presentedViewController];
            [presentedViewController stub:@selector(presentedViewController) andReturn:nestedViewController];
            [nestedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:nestedViewController];
        });

        it(@"should return the lastViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *navigationController = [UINavigationController mock];
            UIViewController *viewControllerLast = [UIViewController mock];
            NSArray *viewControllers = @[[UIViewController mock], viewControllerLast];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:navigationController];
            [navigationController stub:@selector(presentedViewController)];
            [navigationController stub:@selector(viewControllers) andReturn:viewControllers];
            [viewControllerLast stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:viewControllerLast];
        });

        it(@"should return the selectedViewController, when available", ^{
            UIViewController *rootViewController = [UIViewController mock];
            UIViewController *tabBarController = [UITabBarController mock];
            UIViewController *selectedViewController = [UIViewController mock];

            [iam stub:@selector(rootViewController) andReturn:rootViewController];
            [rootViewController stub:@selector(presentedViewController) andReturn:tabBarController];
            [tabBarController stub:@selector(presentedViewController)];
            [tabBarController stub:@selector(selectedViewController) andReturn:selectedViewController];
            [selectedViewController stub:@selector(presentedViewController)];

            UIViewController *topViewController = [iam topViewController];

            [[topViewController should] equal:selectedViewController];
        });
    });

SPEC_END