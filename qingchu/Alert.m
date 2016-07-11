//
//  Alert.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "Alert.h"

@implementation Alert

+ (Alert *)sharedAlert
{
    static Alert *alert = nil;
    static dispatch_once_t  singleton;
    dispatch_once(&singleton, ^{
        alert = [[self alloc] init];
    });
    return alert;
}

- (PopUpView *)popView
{
    if (!_popView) {
        _popView = [[[NSBundle mainBundle] loadNibNamed:@"PopUpView" owner:self options:nil] lastObject];
        self.popView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    }
    return _popView;
}

- (void)showMessage:(NSString*)message
{
    
    self.popView.messageLB.text = message;
    self.popView.completeBlock = NULL;
    [self.popView.sureBTN setTitle:@"确定" forState:UIControlStateNormal];
    [[UIApplication sharedApplication].keyWindow addSubview:self.popView];
}

- (void)showMessage:(NSString *)message okTitle:(NSString *)title action:(CompleteAction)block
{
    self.popView.messageLB.text = message;
    [self.popView.sureBTN setTitle:title forState:UIControlStateNormal];
    self.popView.completeBlock = NULL;
    self.popView.completeBlock = block;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.popView];
}

@end
