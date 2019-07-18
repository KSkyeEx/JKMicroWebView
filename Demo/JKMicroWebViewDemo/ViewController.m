//
//  ViewController.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "ViewController.h"
#import "TestWebController.h"
#import "JKMicroProgress.h"

@interface ViewController ()
@property (nonatomic, strong) JKMicroProgress *progressView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar addSubview:self.progressView];
}
- (IBAction)setPrgress:(UIButton *)sender
{
    [self.progressView setProgress:0.6 animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.progressView setProgress:1.0 animated:YES];
    });
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

- (JKMicroProgress *)progressView
{
    if (!_progressView) {
        CGFloat progressBarHeight = 2.5f;
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
        _progressView = [[JKMicroProgress alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}
@end
