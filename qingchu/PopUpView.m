//
//  PopUpView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "PopUpView.h"

@implementation PopUpView


- (void)awakeFromNib
{
    self.boxView.clipsToBounds = YES;
    self.boxView.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.alphView addGestureRecognizer:tap];
    
    
}

- (IBAction)sure:(UIButton *)sender
{
    void (^complete)()  = self.completeBlock;
    if (complete) {
        complete();
    }
    [self removeFromSuperview];
    
}


- (void)dismiss:(UITapGestureRecognizer *)sender {
    [self removeFromSuperview];
    
    
}

@end
