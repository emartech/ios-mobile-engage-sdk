#import "Kiwi.h"
#import "MEIAMClose.h"
#import "MEIAMViewController.h"

SPEC_BEGIN(MEIAMCloseTests)

    __block MEIAMViewController *viewController;
    __block MEIAMClose *meiamClose;

    beforeEach(^{
        viewController = [MEIAMViewController mock];
        meiamClose = [[MEIAMClose alloc] initWithViewController:viewController];
    });

    describe(@"commandName", ^{

        it(@"should return 'close'", ^{
            [[[MEIAMClose commandName] should] equal:@"close"];
        });

    });

    describe(@"handleMessage:resultBlock:", ^{

        it(@"should close the viewController", ^{
            [[viewController should] receive:@selector(dismissViewControllerAnimated:completion:)];
            [meiamClose handleMessage:@{}
                          resultBlock:nil];
        });

    });

SPEC_END



