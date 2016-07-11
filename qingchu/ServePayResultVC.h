//
//  ServePayResultVC.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/18.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"


@interface ServePayResultVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *resultImageV;
@property (weak, nonatomic) IBOutlet UILabel *resultLB;
@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *rePayBtn;

@property (nonatomic,assign) BOOL paySucceed;

@property (nonatomic,strong) Order *serveOrder;

@end 
