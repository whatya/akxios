//
//  RingView.h
//  LineTest
//
//  Created by ZhuXiaoyan on 15/8/18.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RingView : UIView

@property (nonatomic,strong) CAShapeLayer *bottomRingLayer;
@property (nonatomic,strong) CAShapeLayer *topRingLayer;
@property (nonatomic) float percent;



@end
