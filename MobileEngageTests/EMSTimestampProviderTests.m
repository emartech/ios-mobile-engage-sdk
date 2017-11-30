#import "Kiwi.h"
#import "EMSTimestampProvider.h"


SPEC_BEGIN(TimeStampProviderTests)

    describe(@"TimeStampProvider.currentTimestamp", ^{

        __block EMSTimestampProvider *provider;

        beforeEach(^{
            provider = [EMSTimestampProvider new];
        });

        it(@"should not return nil", ^{
            [[[provider currentTimeStamp] shouldNot] beNil];
        });

        it(@"should return the current time", ^{
            NSNumber *before = @((NSUInteger) (1000 * [[NSDate date] timeIntervalSince1970]));
            NSNumber *result = [provider currentTimeStamp];
            NSNumber *after = @((NSUInteger) (1000 * [[NSDate date] timeIntervalSince1970]));

            [[result should] beBetween:before and:after];
        });
    });

SPEC_END
