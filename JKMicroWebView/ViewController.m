//
//  ViewController.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "ViewController.h"
#import "TestWebController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (IBAction)goToWeb:(UIButton *)sender
{
    NSURL *webURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
    TestWebController *vc = [[TestWebController alloc] initWithURL:webURL];
    vc.webErrorImage = [UIImage imageNamed:@"img_weberror"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goToBaidu:(UIButton *)sender
{
    NSURL *webURL = [NSURL URLWithString:@"https://www.baidu.com"];
    TestWebController *vc = [[TestWebController alloc] initWithURL:webURL];
    vc.webErrorImage = [UIImage imageNamed:@"img_weberror"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
