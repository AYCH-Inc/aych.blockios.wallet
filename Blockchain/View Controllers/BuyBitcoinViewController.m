//
//  BuyBitcoinViewController.m
//  Blockchain
//
//  Created by kevinwu on 1/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BuyBitcoinViewController.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import "TransactionDetailNavigationController.h"
#import "Blockchain-Swift.h"

#define URL_BUY_WEBVIEW_SUFFIX @"/#/intermediate"

@interface BuyBitcoinViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL didInitiateTrade;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, copy) NSString *queuedScript;
@end

NSString* loginWithGuidScript(NSString*, NSString*, NSString*);
NSString* loginWithJsonScript(NSString*, NSString*, NSString*, NSString*, BOOL);

@implementation BuyBitcoinViewController

- (instancetype)initWithRootURL:(NSString *)rootURL {
    self = [super init];
    if (self) {
        WKUserContentController* userController = [[WKUserContentController alloc] init];
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_BUY_COMPLETED];
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_FRONTEND_INITIALIZED];
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_SHOW_TX];

        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userController;

        self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.webView];

        [NSLayoutConstraint activateConstraints:@[
            [self.view.topAnchor constraintEqualToAnchor:self.webView.topAnchor],
            [self.view.leadingAnchor constraintEqualToAnchor:self.webView.leadingAnchor],
            [self.view.trailingAnchor constraintEqualToAnchor:self.webView.trailingAnchor],
            [self.view.bottomAnchor constraintEqualToAnchor:self.webView.bottomAnchor],
        ]];

        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        self.webView.scrollView.scrollEnabled = YES;
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

        NSString *urlString = rootURL ? [rootURL stringByAppendingString:URL_BUY_WEBVIEW_SUFFIX] : [[BlockchainAPI sharedInstance] buyWebViewUrl];
        NSURL *login = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:login
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10.0];
        [self.webView loadRequest:request];
    }
    return self;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *reqUrl = navigationAction.request.URL;

    if (reqUrl != nil && navigationAction.navigationType == WKNavigationTypeLinkActivated && [[UIApplication sharedApplication] canOpenURL:reqUrl]) {

        if (![[reqUrl.absoluteString lowercaseString] hasPrefix:@"http://"] &&
            ![[reqUrl.absoluteString lowercaseString] hasPrefix:@"https://"]) {
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:reqUrl options:@{} completionHandler:nil];

        } else {
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:reqUrl];
            if (safariViewController) {
                [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
            } else {
                UIApplication *application = [UIApplication sharedApplication];
                [application openURL:reqUrl options:@{} completionHandler:nil];
            }
        }

        return decisionHandler(WKNavigationActionPolicyCancel);
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
    if (safariViewController) {
        [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    }

    return nil;
}

- (BOOL)isDebug {
    BOOL debug = NO;
#if DEBUG
    debug = YES;
#endif
    return debug;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    // TODO: migrate to CertificatePinner class
    // Note: All `DEBUG` builds should disable certificate pinning
    // so as QA can see network requests.
    if ([self isDebug]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }else {
        if ([challenge.protectionSpace.host hasSuffix:[[BlockchainAPI sharedInstance] blockchainDotInfo]] ||
            [challenge.protectionSpace.host hasSuffix:[[BlockchainAPI sharedInstance] blockchainDotCom]]) {
            [[CertificatePinner sharedInstance] didReceive:challenge completion:completionHandler];
        } else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

NSString* loginWithGuidScript(NSString* guid, NSString* sharedKey, NSString* password)
{
    return [NSString stringWithFormat:@"activateMobileBuy('%@','%@','%@')", [guid escapedForJS], [sharedKey escapedForJS], [password escapedForJS]];
}


- (void)loginWithGuid:(NSString *)guid sharedKey:(NSString *)sharedKey password:(NSString *)password
{
    NSString *script = loginWithGuidScript(guid, sharedKey, password);
    [self runScriptWhenReady:script];
}

NSString* loginWithJsonScript(NSString* json, NSString* externalJson, NSString* magicHash, NSString* password, BOOL isNew)
{
    return [NSString stringWithFormat:@"activateMobileBuyFromJson('%@','%@','%@','%@',%d)",
            [json escapedForJS],
            [externalJson escapedForJS],
            [magicHash escapedForJS],
            [password escapedForJS],
            isNew];
}

- (void)loginWithJson:(NSString *)json externalJson:(NSString *)externalJson magicHash:(NSString *)magicHash password:(NSString *)password
{
    NSString *script = loginWithJsonScript(json, externalJson, magicHash, password, self.isNew);
    [self runScriptWhenReady:script];
}

- (void)runScript:(NSString *)script
{
    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError * _Nullable error) {
        DLog(@"Ran script with result %@, error %@", [result description], [error localizedDescription]);
        if (error != nil) {

            UIViewController *targetController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;

            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR
                                                                                message:BC_STRING_BUY_WEBVIEW_ERROR_MESSAGE
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
            [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_VIEW_DETAILS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *errorDetailAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:[NSString stringWithFormat:@"%@: %@",[error localizedDescription], error.userInfo] preferredStyle:UIAlertControllerStyleAlert];
                [errorDetailAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
                [targetController presentViewController:errorDetailAlert animated:YES completion:nil];
            }]];

            [targetController presentViewController:errorAlert animated:YES completion:nil];
        }
    }];
}

- (void)runScriptWhenReady:(NSString *)script
{
    if (self.isReady) {
        [self runScript:script];
        self.queuedScript = nil;
    } else {
        self.queuedScript = script;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    DLog(@"Received script message: '%@'", message.name);

    if ([message.name isEqual:WEBKIT_HANDLER_FRONTEND_INITIALIZED]) {
        self.isReady = YES;
        if (self.queuedScript != nil) {
            [self runScript:self.queuedScript];
            self.queuedScript = nil;
        }
    }

    if ([message.name isEqual:WEBKIT_HANDLER_BUY_COMPLETED]) {
        self.didInitiateTrade = YES;
        // Is this when a successful buy has occured?
    }

    if ([message.name isEqual:WEBKIT_HANDLER_SHOW_TX]) {
        [self dismissViewControllerAnimated:YES completion:^(){
            [self.delegate showCompletedTrade:message.body];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    if ([self.navigationController.presentedViewController isMemberOfClass:[UIImagePickerController class]] ||
        [self.navigationController.presentedViewController isMemberOfClass:[TransactionDetailNavigationController class]] ||
        [self.navigationController.presentedViewController isMemberOfClass:[SFSafariViewController class]]) {
        return;
    }

    if (self.didInitiateTrade) {
        [self.delegate watchPendingTrades:YES];
    } else {
        [self.delegate watchPendingTrades:NO];
    }

    if (self.isReady) {
        [self runScript:@"teardown()"];
    }

    self.queuedScript = nil;
    self.didInitiateTrade = NO;
    self.isReady = NO;
}

@end
