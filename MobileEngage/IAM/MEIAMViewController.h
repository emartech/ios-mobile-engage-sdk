//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void (^MECompletionHandler)();

@interface MEIAMViewController : UIViewController


- (instancetype)initWithMessageHandler:(id <WKScriptMessageHandler>)messageHandler;

- (void)loadMessage:(NSString *)message
  completionHandler:(MECompletionHandler)completionHandler;

@end