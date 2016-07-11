//
//  ClockCell.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/7.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clock.h"

typedef void(^CloseClock)(Clock *clock,BOOL isOn);
typedef void(^DeleteClock)(Clock *clock);

@interface ClockCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLB;
@property (weak, nonatomic) IBOutlet UILabel *repeatLB;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (nonatomic,strong) Clock *model;

@property (nonatomic,copy) CloseClock clockOff;
@property (nonatomic,copy) DeleteClock delClock;

@end
