//
//  ClockCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "ClockCell.h"

@implementation ClockCell

- (void)awakeFromNib {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteClock:)];
    [self addGestureRecognizer:longPress];
}

- (void)deleteClock:(UILongPressGestureRecognizer* )obj
{
    if (obj.state == UIGestureRecognizerStateBegan) {
         self.delClock(self.model);
    }
}

- (void)setModel:(Clock *)model
{
    _model = model;
    self.timeLB.text = [model.clockTime substringWithRange:NSMakeRange(0, 5)];
    self.switcher.on = [model.isValid isEqualToString:@"1"];
    self.repeatLB.text = [self formatRepeatString:model.schedule];
}

- (IBAction)toogle:(UISwitch *)sender
{
    self.clockOff(self.model,sender.isOn);
}

- (NSString*)formatRepeatString:(NSString*)string
{
    if ([string isEqualToString:@"-1"]) {
        return @"只响一次";
    }
    
    NSArray *strs = [string componentsSeparatedByString:@","];
    
    if (strs.count == 7) {
        return @"每天";
    }
    
    NSString *repeatStr = @"";
    for (NSString *index in strs){
        NSString *dayStr = [self dayWithNumber:index];
        repeatStr = [repeatStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",dayStr]];
    }
    
    return repeatStr;
}

- (NSString*)dayWithNumber:(NSString*)numberString
{
    int index = [numberString intValue];
    return @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"",@"星期六",@"星期日"][index-1];
}

@end
