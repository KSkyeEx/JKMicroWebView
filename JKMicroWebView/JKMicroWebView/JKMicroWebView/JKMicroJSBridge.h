//
//  JKMicroJSBridge.h
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^JKJSCallback)(NSDictionary *response);
typedef void (^JKJSHandle)(NSDictionary *params, JKJSCallback callback);

@interface JKMicroJSBridge : NSObject

+ (instancetype)bridgeForWebView:(WKWebView *)webView;
/**
 注册原生函数，供js调用

 @param handlerName 函数名
 @param handler 原生处理方法
 */
- (void)registerHandler:(NSString *)handlerName handler:(JKJSHandle)handler;
/**
 移除注册的原生函数,移除之后js将不能在调用到这个OC方法了，需要重新注册之后才能调用

 @param handlerName 函数名
 */
- (void)removeHandler:(NSString *)handlerName;
/**
 oc调用js

 @param handlerName js函数名
 */
- (void)callHandler:(NSString *)handlerName;
/**
 co调用js

 @param handlerName js函数名
 @param data 传递给js的数据
 */
- (void)callHandler:(NSString *)handlerName data:(id)data;
/**
 oc调用js

 @param handlerName 函数名
 @param data 传递给js的数据
 @param responseCallback JS回调给原生
 */
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(JKJSCallback)responseCallback;

@end
