//
//  InputPanle.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "InputPanle.h"

@implementation InputPanle


- (IBAction)sure:(UIButton *)sender
{
    PanleAction block = self.okBtnClickedAction;
    if (block) {
        block();
    }
}
- (IBAction)dismissKeyboard:(UIButton *)sender
{
    PanleAction block = self.dismisKeyboardAction;
    if (block) {
        block();
    }
}

@end
