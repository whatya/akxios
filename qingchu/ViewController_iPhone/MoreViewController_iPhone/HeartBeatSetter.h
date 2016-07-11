//
//  HeartBeatSetter.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/30.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartBeatSetter : UITableViewController

@property (copy,nonatomic) void(^setCallbac)();

@end
