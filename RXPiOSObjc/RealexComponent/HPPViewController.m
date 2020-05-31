//
//  HPPViewController.m
//  RXPiOSObjc
//
//  Created by Helio Martín de la Torre on 19/02/2020.
//  Copyright © 2020 Helio Martín de la Torre. All rights reserved.
//

#import "HPPViewController.h"

@interface HPPViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation HPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialiseWebView];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

-(void)initialiseWebView {
    NSString *viewScriptString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *viewScript = [[WKUserScript alloc] initWithSource:viewScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly: YES];
    
    WKUserContentController *userContentController = [WKUserContentController new];
    [userContentController addUserScript:viewScript];
    [userContentController addScriptMessageHandler:self name:@"callbackHandler"];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptEnabled = YES;
    
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.view = self.webView;
}

-(void)closeView {
    [self.manager HPPViewControllerWillDismiss];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadRequest:(NSURLRequest*)request {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:NO];
            
            [self.manager HPPViewControllerFailedWithError:error];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if (data.length == 0) {
            [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:NO];

            [self.manager HPPViewControllerFailedWithError:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:htmlString baseURL:request.URL];
            });
        }
    }];
    [dataTask resume];
}

#pragma mark - WKWebView Delegate Callbacks

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:YES];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:NO];
    
     [self.manager HPPViewControllerFailedWithError:error];
     [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%@",navigationResponse.response.URL);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - Javascript Message Callback

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message body: %@", message.body);
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([message.body isKindOfClass:NSString.class]) {
        if ([message.body containsString:@"Error:"]) {
            [self.manager HPPViewControllerManagerFailedWithPayError:message.body];
        }else {
            [self.manager HPPViewControllerCompletedWithResult:message.body];
        }
    }else {
        [self.manager HPPViewControllerFailedWithError:nil];
    }
    
}

@end
