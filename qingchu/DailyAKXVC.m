//
//  DailyAKXVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/22.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "DailyAKXVC.h"
#import "ProgressHUD.h"

@interface DailyAKXVC()<UIWebViewDelegate>

@end

@implementation DailyAKXVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.inputUrl.length > 0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.inputUrl]]];
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [ProgressHUD show:@"加载中..."];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ProgressHUD dismiss];
}

@end
