#import "Kiwi.h"
#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"

MEIAMJSCommandFactory *_factory;

SPEC_BEGIN(MEIAMJSCommandFactoryTests)

    beforeEach(^{
        _factory = [MEIAMJSCommandFactory new];
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
    });

SPEC_END
