//
//  RingView.m
//  LineTest
//
//  Created by ZhuXiaoyan on 15/8/18.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import "RingView.h"

@interface RingView ()

@end

@implementation RingView

- (void)drawRect:(CGRect)rect
{
    NSLog(@"awakeFromNib invoked!");
    //绘制底图
    self.bottomRingLayer = [CAShapeLayer layer];
    self.bottomRingLayer.fillColor = [UIColor clearColor].CGColor;
    self.bottomRingLayer.strokeColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1].CGColor;
    self.bottomRingLayer.lineWidth = 4.0;
    self.bottomRingLayer.lineJoin = kCALineCapRound;
    
    //self.bottomRingLayer.lineDashPattern = @[@1,@2];
    CGMutablePathRef bottomPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(bottomPath, NULL, CGRectMake(10, 10,self.bounds.size.width-40,self.bounds.size.width-40));
    self.bottomRingLayer.path = bottomPath;
    CGPathRelease(bottomPath);
    [self.layer addSublayer:self.bottomRingLayer];
    
    //绘制顶部进度条
    self.topRingLayer = [CAShapeLayer layer];
    self.topRingLayer.fillColor = [UIColor clearColor].CGColor;
    self.topRingLayer.strokeColor = [UIColor redColor].CGColor;
    self.topRingLayer.lineWidth = 4.0;
    self.topRingLayer.lineJoin = kCALineCapRound;
    
    //self.topRingLayer.lineDashPattern = @[@1,@2];
    CGMutablePathRef topPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(topPath, NULL, CGRectMake(10, 10, self.bounds.size.width-40, self.bounds.size.width-40));
    self.topRingLayer.path = topPath;
    self.topRingLayer.strokeStart = 0;
    self.topRingLayer.strokeEnd = self.percent;
    CGPathRelease(topPath);
    [self.layer addSublayer:self.topRingLayer];

}


- (void)setPercent:(float)percent
{
    _percent = percent;
    self.topRingLayer.strokeEnd = percent;
    [self.topRingLayer addAnimation:[self animateTopLayerWith:percent] forKey:@"strokeEnd"];
    
}


- (CABasicAnimation*)animateTopLayerWith:(float)value
{
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @0.0;
    pathAnimation.toValue = @(value);
    pathAnimation.autoreverses = NO;
    pathAnimation.removedOnCompletion = NO;
    return pathAnimation;
}

@end
