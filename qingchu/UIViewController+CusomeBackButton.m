//
//  UIViewController+CusomeBackButton.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "UIViewController+CusomeBackButton.h"

@implementation UIViewController (CusomeBackButton)

- (void)setUpBackButton
{
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName]=[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttrs];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"CustomBackButton"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 16);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
