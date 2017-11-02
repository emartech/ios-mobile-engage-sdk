#import "Kiwi.h"
#import "MEIAMViewController.h"

@interface WKScriptMessageHandlerMock : NSObject <WKScriptMessageHandler>
@end

@implementation WKScriptMessageHandlerMock
@end


SPEC_BEGIN(MEIAMViewControllerTests)

    describe(@"loadMessage:completionHandler:", ^{

        it(@"should call completionHandler, when content loaded", ^{
            NSString *message = @"<!DOCTYPE html>\n"
                    "<html lang=\"en\">\n"
                    "  <head>\n"
                    "    <script>\n"
                    "      window.onload = function() {\n"
                    "        window.webkit.messageHandlers.IAMDidAppear.postMessage({success:true});\n"
                    "      };\n"
                    "    </script>\n"
                    "  </head>\n"
                    "  <body style=\"background: transparent;\">\n"
                    "  </body>\n"
                    "</html>";
            XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"wait"];


            WKScriptMessageHandlerMock *messageHandler = [WKScriptMessageHandlerMock mock];
            [[messageHandler shouldEventually] receive:@selector(userContentController:didReceiveScriptMessage:) withArguments:any(), any()];
            KWCaptureSpy *spy = [messageHandler captureArgument:@selector(userContentController:didReceiveScriptMessage:)
                                                        atIndex:1];
            MEIAMViewController *iamViewController = [[MEIAMViewController alloc] initWithMessageHandler:messageHandler];

            [iamViewController loadMessage:message
                         completionHandler:^{
                             [exp fulfill];
                         }];
            [XCTWaiter waitForExpectations:@[exp]
                                   timeout:30];

            WKScriptMessage *scriptMessage = spy.argument;
            [[scriptMessage.name shouldEventually] equal:@"IAMDidAppear"];
            [[scriptMessage.body shouldEventually] equal:@{@"success": @YES}];

        });

    });

SPEC_END