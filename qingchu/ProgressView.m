//
//  ProgressView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/25.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "ProgressView.h"


@implementation ProgressView


- (void)drawRect:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat radius = MAX(rect.size.height, rect.size.height);
    CGFloat arcWidth = 10;
    
    CGFloat startAngle = 3 * M_PI / 4;
    CGFloat endAngle = M_PI / 4;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius/2 - arcWidth/2
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    
    path.lineWidth = arcWidth;
    [[UIColor colorWithRed:218/255.0 green:217/255.0 blue:218/255.0 alpha:1] setStroke];
    [path stroke];
    
}


@end
