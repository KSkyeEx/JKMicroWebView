//
//  WKWebViewController.h
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKMicroView.h"
#import "JKMicroJSBridge.h"

@class JKMicroController;

#ifndef BRI_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define BRI_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define BRI_REQUIRES_SUPER
#endif
#endif

#pragma mark - MSWebViewControllerDelegate
@protocol WKWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerWillGoBack:(JKMicroController *)webViewController;
- (void)webViewControllerWillGoForward:(JKMicroController *)webViewController;
- (void)webViewControllerWillReload:(JKMicroController *)webViewController;
- (void)webViewControllerWillStop:(JKMicroController *)webViewController;
- (void)webViewControllerDidStartLoad:(JKMicroController *)webViewController;
- (void)webViewControllerDidFinishLoad:(JKMicroController *)webViewController;
- (void)webViewController:(JKMicroController *)webViewController didFailLoadWithError:(NSError *)error;
@end

@interface JKMicroController : UIViewController
//当前Web控件
@property (nonatomic, strong, readonly) JKMicroView *webView;
//与JS交互的bridge
@property (nonatomic, strong, readonly) JKMicroJSBridge *bridge;
//进度条的进度颜色
@property (nonatomic, strong) UIColor *progressTintColor;
//超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInternal;
// Web缓存模式
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
//代理对象
@property (nonatomic, weak) id<WKWebViewControllerDelegate> delegate;
//是否可以goback
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
//是否可以goforward
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
//Web是否正在加载中
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
//是否允许goback返回,默认是YES 允许返回
@property (nonatomic, assign) BOOL allowBack;
//Web加载错误时展示的图片
@property (nonatomic, strong) UIImage *webErrorImage;
#pragma mark - 初始化方法
- (instancetype)initWithURLString:(NSString *)urlString;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURLRequest:(NSURLRequest *)requst;

- (void)loadHTMLTemplate:(NSString *)htmlTemplate;
//清除所有缓存
- (void)clearAllWebCache;
@end

#pragma mark - BRIWebViewController (SubclassHooks)
//以下方法供子类调用
@interface JKMicroController (SubclassHooks)
/**
 如果needInterceptReq设置为YES,会调用该方法,为了保证流程可以正常执行,当needInterceptReq设置为YES时子类务必重写该方法

 @param navigationAction
 通过该参数可以获取request和url,可以自行设置cookie或给url追加参数,然后让webView重新loadRequest
 */
- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

/*
 注意:子类调用以下方法需要在方法实现中调用super
 */

/**
 即将后退
 */
- (void)willGoBack BRI_REQUIRES_SUPER;

/**
 即将前进
 */
- (void)willGoForward BRI_REQUIRES_SUPER;

/**
 即将刷新
 */
- (void)willReload BRI_REQUIRES_SUPER;

/**
 即将结束
 */
- (void)willStop BRI_REQUIRES_SUPER;

/**
 开始加载
 */
- (void)didStartLoad BRI_REQUIRES_SUPER;

/**
 已经加载完成
 */
- (void)didFinishLoad BRI_REQUIRES_SUPER;

/**
 加载出错
 */
- (void)didFailLoadWithError:(NSError *)error BRI_REQUIRES_SUPER;

@end
