//
//  HeartRateVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/25.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartRateVC : UIViewController

@property (nonatomic,strong) NSDictionary *mesuredPulse;
@property (nonatomic,strong) NSString     *imei;
- (void)initUI;

@end
