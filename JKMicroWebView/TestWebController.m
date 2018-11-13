//
//  TestWebController.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "TestWebController.h"

@implementation TestWebController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.bridge registerHandler:@"jsToOcFunction1" handler:^(NSDictionary *params, JKJSCallback callback) {
        callback(@{@"data": @"OC callback JS"});
    }];
    
    [self.bridge registerHandler:@"jsToOcFunction2" handler:^(NSDictionary *params, JKJSCallback callback) {
        NSLog(@"%@", params);
        callback(@{@"data": @"OC callback JS"});
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OCTOJS" style:(UIBarButtonItemStyleDone) target:self action:@selector(ocToJs)];
}

- (void)ocToJs
{
    [self.bridge callHandler:@"changeColor" data:@"oc 传给 js 的数据" responseCallback:^(NSDictionary *response) {
        NSLog(@"%@", response);
    }];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}
@end
