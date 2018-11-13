//
//  AppDelegate.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
/*
 <meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0">
 function jsToOcFunction1()
 {
 window.JKMicroJSBridge.callHandler('jsToOcFunction1',function(response) {
 alert("收到了回调1")
 })
 }
 
 function jsToOcFunction2()
 {
 window.JKMicroJSBridge.callHandler('jsToOcFunction2',{'data":"我是参数'},function(response) {
 alert(response)
 })
 }
 
 function showAlert()
 {
 alert("被OC截获到了");
 }
 
 //OC调用JS改变背景色
 window.JKMicroJSBridge.registerHandler('changeColor', function(data, responseCallback) {
 document.body.style.backgroundColor = randomColor();
 var responseData = { 'Javascript Says':'Right back atcha!' }
 responseCallback(responseData)
 })
 
 //随机生成颜色
 function randomColor()
 {
 var r=Math.floor(Math.random()*256);
 var g=Math.floor(Math.random()*256);
 var b=Math.floor(Math.random()*256);
 return "rgb("+r+','+g+','+b+")";//所有方法的拼接都可以用ES6新特性`其他字符串{$变量名}`替换
 }
 
 */
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
