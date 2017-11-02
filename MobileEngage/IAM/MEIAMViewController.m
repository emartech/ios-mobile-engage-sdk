//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMViewController.h"

@interface MEIAMViewController () <WKNavigationDelegate, WKScriptMessageHandler>

@property(nonatomic, strong) MECompletionHandler completionHandler;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, weak) id <WKScriptMessageHandler> messageHandler;

@end

@implementation MEIAMViewController

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColor.clearColor];
}

#pragma mark - Public methods

- (instancetype)initWithMessageHandler:(id <WKScriptMessageHandler>)messageHandler {
    self = [super init];
    if (self) {
        _messageHandler = messageHandler;
    }
    return self;
}

- (void)loadMessage:(NSString *)message
  completionHandler:(MECompletionHandler)completionHandler {
    _completionHandler = completionHandler;
    if (!self.webView) {
        _webView = [self createWebView];
        [self addFullscreenView:self.webView];
    }
    [self.webView loadHTMLString:message
                         baseURL:nil];
}

#pragma mark - WKNavigationDelegate

- (void)    webView:(WKWebView *)webView
didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.completionHandler) {
        self.completionHandler();
    }
}

#pragma mark - Private methods

- (WKWebView *)createWebView {
    WKProcessPool *processPool = [WKProcessPool new];
    WKWebViewConfiguration *webViewConfiguration = [WKWebViewConfiguration new];
    WKUserContentController *userContentController = [WKUserContentController new];

    [userContentController addScriptMessageHandler:self.messageHandler //TODO: change this for JS script handling
                                              name:@"IAMDidAppear"];
    [webViewConfiguration setProcessPool:processPool];
    [webViewConfiguration setUserContentController:userContentController];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                            configuration:webViewConfiguration];
    [webView setNavigationDelegate:self];
    [webView setOpaque:NO];
    [webView setBackgroundColor:UIColor.clearColor];
    [webView.scrollView setBackgroundColor:UIColor.clearColor];
    [webView.scrollView setScrollEnabled:NO];
    [webView.scrollView setBounces:NO];
    [webView.scrollView setBouncesZoom:NO];
    return webView;
}

- (void)addFullscreenView:(UIView *)view {
    [self.view addSubview:view];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    [self.view addConstraints:@[widthConstraint, heightConstraint]];
    [self.view layoutIfNeeded];
}

@end