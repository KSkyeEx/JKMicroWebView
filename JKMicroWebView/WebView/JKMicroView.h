//
//  JKMicroView.h
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface JKMicroView : WKWebView

//是否允许手势goback返回,默认是NO
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
