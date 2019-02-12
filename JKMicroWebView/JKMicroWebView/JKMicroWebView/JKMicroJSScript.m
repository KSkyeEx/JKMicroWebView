//
//  JKMicroJSScript.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "JKMicroJSScript.h"

#define __jkMicro_js_func__(x) #x

NSString *WebViewJavascriptBridge_js(void) {
    NSString *preprocessorJSCode = @__jkMicro_js_func__(
        (function() {
            //如果已经初始化了，则返回。
            if (window.JKMicroJSBridge) {
                return;
            }
            if (!window.onerror) {
                window.onerror = function(msg, url, line) {
                    console.log("JKMicroJSBridge: ERROR:" + msg + "@" + url + ":" + line);
                }
            }
            window.JKMicroJSBridge = {
                registerHandler : registerHandler,
                callHandler : callHandler,
                receiveMessageFromObjC : receiveMessageFromObjC,
            };
            var messageHandlers = {};
            var responseCallbacks = {};
            var uniqueId = 1;
            //提供OC调用的方法
            function registerHandler(handlerName, handler) {
                messageHandlers[handlerName] = handler;
            }
            //提供JS调用OC的方法
            function callHandler(handlerName, data, responseCallback) {
                if (arguments.length == 2 && typeof data == 'function') {
                    responseCallback = data;
                    data = null;
                }
                doSend({handlerName : handlerName, data : data}, responseCallback);
            }
            //向OC发送消息
            function doSend(message, responseCallback) {
                if (responseCallback) {
                    var callbackId = 'jk_' + (uniqueId++) + '_' + new Date().getTime();
                    responseCallbacks[callbackId] = responseCallback;
                    message['callbackId'] = callbackId;
                }
                window.webkit.messageHandlers.JKMicroHandler.postMessage(message);
            }
            //接收到从OC传递过来的消息
            function receiveMessageFromObjC(messageJSON) {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            doSend({handlerName : message.handlerName, responseId : callbackResponseId, responseData : responseData});
                        };
                    }
                    var handler = messageHandlers[message.handlerName];
                    if (!handler) {
                        console.log("JKMicroJSBridge: WARNING: no handler for message from ObjC:", message);
                    } else {
                        handler(message.data, responseCallback);
                    }
                }
            }
            // end
        })(););
    return preprocessorJSCode;
}
