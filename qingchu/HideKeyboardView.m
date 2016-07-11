//
//  HideKeyboardView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "HideKeyboardView.h"

@implementation HideKeyboardView

- (IBAction)dismiss:(UIButton *)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}


@end
