//
//  JKMicroJSBridge.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "JKMicroJSBridge.h"
#import "JKMicroJSScript.h"

@interface JKMicroJSBridge () <WKScriptMessageHandler>
@property (nonatomic, strong) NSMutableDictionary *responseCallbacks;
@property (nonatomic, strong) NSMutableDictionary *messageHandlers;
@property (nonatomic, assign) long uniqueId;
@property (nonatomic, weak) WKWebView *webView;
@end

static NSString *nameSpace = @"JKMicroHandler";

@implementation JKMicroJSBridge
#pragma makr - public

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}
+ (instancetype)bridgeForWebView:(WKWebView *)webView
{
    NSString *bridgeJSString = WebViewJavascriptBridge_js();
    WKUserScript *injectScript = [[WKUserScript alloc] initWithSource:bridgeJSString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    JKMicroJSBridge *bridge = [[JKMicroJSBridge alloc] init];
    bridge.webView = webView;
    // 通过JS与webview内容交互
    [bridge.webView.configuration.userContentController addUserScript:injectScript];
    // 我们可以在WKScriptMessageHandler代理中接收到
    [bridge.webView.configuration.userContentController addScriptMessageHandler:bridge name:nameSpace];
    return bridge;
}

- (void)registerHandler:(NSString *)handlerName handler:(JKJSHandle)handler
{
    self.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName
{
    [self.messageHandlers removeObjectForKey:handlerName];
}

- (void)callHandler:(NSString *)handlerName
{
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data
{
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(JKJSCallback)responseCallback
{
    [self sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)reset
{
    [self.responseCallbacks removeAllObjects];
    [self.messageHandlers removeAllObjects];
    self.uniqueId = 1;
}

#pragma makr - private
- (void)sendData:(id)data responseCallback:(JKJSCallback)responseCallback handlerName:(NSString *)handlerName
{
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    if (data) {
        message[@"data"] = data;
    }
    if (responseCallback) {
        NSString *callbackId = [NSString stringWithFormat:@"objc_jk_%ld", self.uniqueId++];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }

    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self sendMessage:message];
}

- (void)sendMessage:(NSDictionary *)message
{
    NSString *messageJSON = [self serializeMessage:message];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];

    NSString *javascriptCommand = [NSString stringWithFormat:@"window.JKMicroJSBridge.receiveMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
        });
    }
}

- (NSString *)serializeMessage:(id)message
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(NSJSONWritingPrettyPrinted) error:nil] encoding:NSUTF8StringEncoding];
}

#pragma mark - JKLazy
- (NSMutableDictionary *)messageHandlers
{
    if (!_messageHandlers) {
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return _messageHandlers;
}
- (NSMutableDictionary *)responseCallbacks
{
    if (!_responseCallbacks) {
        _responseCallbacks = [NSMutableDictionary dictionary];
    }
    return _responseCallbacks;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:nameSpace]) {
        [self flushMessage:message.body];
    }
}

- (void)flushMessage:(NSDictionary *)message
{
    if (message == nil || message.allKeys.count == 0) {
        NSLog(@"JKMicroJSBridge: WARNING: ObjC got nil while fetching the message "
              @"queue JSON from webview. This can happen if the JKMicroJSBridge "
              @"JS is not currently present in the webview, e.g if the webview "
              @"just loaded a new page.");
        return;
    }
    NSString *responseId = message[@"responseId"];
    if (responseId) {
        //这里是oc调用js后，js回调给oc的处理
        JKJSCallback responseCallback = self.responseCallbacks[responseId];
        responseCallback(message[@"responseData"]);
        [self.responseCallbacks removeObjectForKey:responseId];
    } else {
        //这里是js调用oc之后，oc给js的回调处理
        JKJSCallback responseCallback = NULL;
        NSString *callbackId = message[@"callbackId"];
        if (callbackId) {
            responseCallback = ^(id responseData) {
                if (responseData == nil) {
                    responseData = [NSNull null];
                }
                NSDictionary *msg = @{
                    @"responseId" : callbackId,
                    @"responseData" : responseData
                };
                [self sendMessage:msg];
            };
        } else {
            responseCallback = ^(id ignoreResponseData) {
                // Do nothing
            };
        }
        JKJSHandle handler = self.messageHandlers[message[@"handlerName"]];
        if (!handler) {
            NSLog(@"JKMicroJSBridge, No handler for message from JS: %@", message);
        }
        handler(message[@"data"], responseCallback);
    }
}

- (void)dealloc
{
    //清除handler
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:nameSpace];
    //清除UserScript
    [self.webView.configuration.userContentController removeAllUserScripts];
}
@end
