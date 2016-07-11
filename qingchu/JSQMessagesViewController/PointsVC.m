//
//  PointsVC.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/10/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "PointsVC.h"

@interface PointsVC ()

@end

@implementation PointsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.urlString);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}


@end
