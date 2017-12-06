#import "Kiwi.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMProtocol.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"

MEIAMJSCommandFactory *_factory;

SPEC_BEGIN(MEIAMJSCommandFactoryTests)

    beforeEach(^{
        _factory = [MEIAMJSCommandFactory new];
    });

    describe(@"initWithMEIAM:", ^{
        it(@"should initialize MEIAM property", ^{
            id meiam = [KWMock mockForProtocol:@protocol(MEIAMProtocol)];
            MEIAMJSCommandFactory *meiamjsCommandFactory = [[MEIAMJSCommandFactory alloc] initWithMEIAM:meiam];

            [[@([meiamjsCommandFactory.meiam isEqual:meiam]) should] beYes];
        });
    });

    describe(@"commandByName", ^{
        it(@"should return MEIAMRequestPushPermission command when the given name is: requestPushPermission", ^{
            MEIAMRequestPushPermission *command = [_factory commandByName:@"requestPushPermission"];
            [[command should] beKindOfClass:[MEIAMRequestPushPermission class]];
        });

        it(@"should return MEIAMOpenExternalLink command when the given name is: openExternalLink", ^{
            MEIAMOpenExternalLink *command = [_factory commandByName:@"openExternalLink"];
            [[command should] beKindOfClass:[MEIAMOpenExternalLink class]];
        });

        it(@"should return MEIAMClose command when the given name is: close", ^{
            MEIAMClose *command = [_factory commandByName:@"close"];
            [[command should] beKindOfClass:[MEIAMClose class]];
        });

        it(@"should return MEIAMTriggerAppEvent command when the given name is: triggerAppEvent", ^{
            MEIAMTriggerAppEvent *command = [_factory commandByName:@"triggerAppEvent"];
            [[command should] beKindOfClass:[MEIAMTriggerAppEvent class]];
        });
    });

SPEC_END
