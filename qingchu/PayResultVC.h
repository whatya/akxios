//
//  PayResultVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/16.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface PayResultVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *resultIMV;
@property (weak, nonatomic) IBOutlet UILabel *resultLB;
@property (weak, nonatomic) IBOutlet UIButton *reOrederBtn;
@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic,assign) BOOL paySucceed;
@property (nonatomic,strong) Order *order;

@end
