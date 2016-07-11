//
//  CanHideTF.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "CanHideTF.h"

@implementation CanHideTF

- (void)awakeFromNib
{
    HideKeyboardView *hideKeyboard = [[[NSBundle mainBundle] loadNibNamed:@"HideKeyboardBanner" owner:self options:nil] lastObject];
    self.inputAccessoryView = hideKeyboard;
}

@end
