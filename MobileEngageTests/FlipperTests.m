#import "Kiwi.h"
#import "Experimental.h"

@interface Experimental(Tests)
+ (void)reset;
@end

SPEC_BEGIN(FlipperTest)


    describe(@"Experimental.featureEnabled", ^{

        beforeEach(^{
            [Experimental reset];
        });

        it(@"should default to being turned off", ^{
            [[theValue([Experimental isFeatureEnabled:INAPP_MESSAGING]) should] beFalse];
        });

        it(@"should return true if the flipper is turned on", ^{
            [Experimental enableFeature:INAPP_MESSAGING];
            [[theValue([Experimental isFeatureEnabled:INAPP_MESSAGING]) should] beTrue];
        });

        it(@"should return true for both features if we enabled both", ^{
            [Experimental enableFeature:INAPP_MESSAGING];
            NSString *feature = @"secondFeature";
            [Experimental enableFeature:feature];
            [[theValue([Experimental isFeatureEnabled:INAPP_MESSAGING]) should] beTrue];
            [[theValue([Experimental isFeatureEnabled:feature]) should] beTrue];
        });

    });

    describe(@"Experimental.reset", ^{
        it(@"should reset the state", ^{
            [Experimental enableFeature:INAPP_MESSAGING];
            [Experimental reset];
            [[theValue([Experimental isFeatureEnabled:INAPP_MESSAGING]) should] beFalse];
        }) ;
    });

SPEC_END
