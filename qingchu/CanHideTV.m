//
//  CanHideTV.m
//  qingchu
//
//  Created by 张宝 on 16/7/9.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "CanHideTV.h"

@implementation CanHideTV
- (void)awakeFromNib
{
    HideKeyboardView *hideKeyboard = [[[NSBundle mainBundle] loadNibNamed:@"HideKeyboardBanner" owner:self options:nil] lastObject];
    self.inputAccessoryView = hideKeyboard;
}

@end
