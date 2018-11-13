//
//  RRKWebView.h
//  ByRongInvestment
//
//  Created by byRong on 2018/10/15.
//  Copyright © 2018 Hangzhou Byrong Investment Management Co., Ltd. All rights
//  reserved.
//

#import <WebKit/WebKit.h>

@interface JKMicroWebView : WKWebView

//是否允许goback返回,默认是YES
@property (nonatomic, assign) BOOL allowBack;

#pragma mark - load request
- (void)jk_loadRequestURLString:(NSString *)urlString;

- (void)jk_loadRequestURL:(NSURL *)url;

- (void)jk_loadRequestURL:(NSURL *)url cookie:(NSDictionary *)params;

- (void)jk_loadRequest:(NSURLRequest *)requset;

- (void)jk_loadHTMLTemplate:(NSString *)htmlTemplate;

#pragma mark - Cache
+ (void)jk_clearAllWebCache;

- (void)jk_clearBrowseHistory;
@end
