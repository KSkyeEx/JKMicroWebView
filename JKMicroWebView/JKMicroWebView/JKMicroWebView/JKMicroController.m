//
//  WKWebViewController.m
//  ByRongInvestment
//
//  Created by byRong on 2018/10/16.
//  Copyright © 2018 Hangzhou Byrong Investment Management Co., Ltd. All rights
//  reserved.
//

#import "JKMicroController.h"
#import "JKMicroProgress.h"

@interface JKMicroController () <WKNavigationDelegate, WKUIDelegate>
//当前Web控件
@property (nonatomic, strong, readwrite) JKMicroView *webView;
//与JS交互的jkdge
@property (nonatomic, strong, readwrite) JKMicroJSBridge *bridge;
@property (nonatomic, strong) JKMicroProgress *progressView; //进度条
@property (nonatomic, strong) NSMutableURLRequest *request; // WebView入口请求
@property (nonatomic, strong) UIImageView *errorImageView; //网页加载错误的时候展示给用户
@end

@implementation JKMicroController
#pragma mark - 初始化
- (instancetype)initWithURLString:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return [self initWithURLRequest:request.copy];
}

- (instancetype)initWithURLRequest:(NSURLRequest *)requst
{
    self.request = requst.mutableCopy;
    return [self init];
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.timeoutInternal = 60.0;
    self.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.allowBack = YES;
}

#pragma mark - View Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove progress view
    [self.progressView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.view addSubview:self.webView];
    [self fetchData];
    self.bridge = [JKMicroJSBridge bridgeForWebView:self.webView];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [UIApplication sharedApplication].statusBarStyle;
}
#pragma mark - UI & Fetch Data

- (void)viewWillLayoutSubviews
{
    self.webView.frame = self.view.bounds;
}
- (void)fetchData
{
    !self.request ?: [self loadURLRequest:self.request];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        [self updateTitleOfWebVC];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - LoadRequest
- (void)loadURLRequest:(NSMutableURLRequest *)request
{
    request.timeoutInterval = self.timeoutInternal;
    request.cachePolicy = self.cachePolicy;
    [self.webView jk_loadRequest:request.copy];
}

#pragma mark - NavigationItem
- (void)updateTitleOfWebVC
{
    NSString *title = self.title;
    title = title.length > 0 ? title : self.webView.title;
    self.navigationItem.title = title.length > 0 ? title : @"未经开发的星球~";
}

#pragma mark - WKNavigationDelegate
//发送请求之前决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

//在收到响应后，决定是否跳转(表示当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。)
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy)) decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self didStartLoad];
}

//接收到服务器跳转请求之后调用(接收服务器重定向时)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation: (null_unspecified WKNavigation *)navigation
{
    
}

//加载失败时调用(加载内容时发生错误时)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) {
        // [webView reloadFromOrigin];
        return;
    }
    [self didFailLoadWithError:error];
}

//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self didFinishLoad];
}

//导航期间发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self didFailLoadWithError:error];
}

// iOS9.0以上异常终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}
#pragma mark - WKNavigationDelegate - 为子类提供的WKWebViewDelegate方法,使用时一定要调用super方法!
- (void)willGoBack
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerWillGoBack:)]) {
        [self.delegate webViewControllerWillGoBack:self];
    }
}

- (void)willGoForward
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerWillGoForward:)]) {
        [self.delegate webViewControllerWillGoForward:self];
    }
}

- (void)willReload
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerWillReload:)]) {
        [self.delegate webViewControllerWillReload:self];
    }
}

- (void)willStop
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerWillStop:)]) {
        [self.delegate webViewControllerWillStop:self];
    }
}

- (void)didStartLoad
{
    [self.errorImageView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.progressView setProgress:0.6 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [self.delegate webViewControllerDidStartLoad:self];
    }
}

- (void)didFinishLoad
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateTitleOfWebVC];
    [self.progressView setProgress:1.0 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateTitleOfWebVC];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        [self.delegate webViewController:self didFailLoadWithError:error];
    }
    [self.progressView setProgress:1.0 animated:YES];
    [self.view addSubview:self.errorImageView];
}
#pragma mark - WKWebViewUIDelegate
// 提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    if (self && self.isViewLoaded && self.webView && [self.webView superview]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completionHandler();
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        completionHandler();
    }
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    if (self && self.isViewLoaded && self.webView && [self.webView superview]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            completionHandler(YES);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            completionHandler(NO);
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        completionHandler(NO);
    }
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler
{
    if (self && self.isViewLoaded && self.webView && [self.webView superview]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt ? prompt : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.textColor = [UIColor blackColor];
            textField.placeholder = defaultText ? defaultText : @"";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            completionHandler([[alert.textFields lastObject] text]);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            completionHandler(nil);
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        completionHandler(nil);
    }
}
#pragma mark - goBack & goForward
- (BOOL)isLoading
{
    return self.webView.isLoading;
}

- (BOOL)canGoBack
{
    return self.webView.canGoBack;
}

- (BOOL)canGoForward
{
    return self.webView.canGoForward;
}

- (void)goBack
{
    [self willGoBack];
    [self.webView goBack];
}

- (void)reload
{
    [self willReload];
    [self.webView reload];
}

- (void)forward
{
    [self willGoForward];
    [self.webView goForward];
}

- (void)stopLoading
{
    [self willStop];
    [self.webView stopLoading];
}

#pragma mark - 懒加载
- (UIImageView *)errorImageView
{
    if (!_errorImageView) {
        _errorImageView = [[UIImageView alloc] initWithFrame:self.webView.bounds];
        NSAssert(self.webErrorImage, @"这里需要一张图片");
        _errorImageView.image = self.webErrorImage;
        _errorImageView.contentMode = UIViewContentModeCenter;
        _errorImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webReload)];
        [_errorImageView addGestureRecognizer:tapGes];
    }
    return _errorImageView;
}
- (void)webReload
{
    !self.request ?: [self loadURLRequest:self.request];
}
- (JKMicroProgress *)progressView
{
    if (!_progressView) {
        CGFloat progressBarHeight = 2.5f;
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
        _progressView = [[JKMicroProgress alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        if (self.progressTintColor) {
            _progressView.progressBarView.backgroundColor = self.progressTintColor;
        }
    }
    return _progressView;
}

- (JKMicroView *)webView
{
    if (!_webView) {
        _webView = [[JKMicroView alloc] initWithFrame:self.view.bounds];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.allowBack = self.allowBack;
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}
#pragma mark - Ohter Method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeFromSuperview];
    self.webView = nil;
    [self clearAllWebCache];
}

- (void)clearAllWebCache
{
    [JKMicroView jk_clearAllWebCache];
}

- (void)loadHTMLTemplate:(NSString *)htmlTemplate
{
    [self.webView jk_loadHTMLTemplate:htmlTemplate];
}

@end
