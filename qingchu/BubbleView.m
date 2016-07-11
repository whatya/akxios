//
//  BubbleView.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/11/12.
//  Copyright © 2015年 whtriples. All rights reserved.
//

#import "BubbleView.h"

#define     Arror_height        8
#define     BubbleRadius        30
#define     DefaultBKColor      [UIColor colorWithRed:233/255.0 green:59/255.0 blue:60/255.0 alpha:1].CGColor

@implementation BubbleView


#pragma mark- drawBorder
-(void)drawRect:(CGRect)rect{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)context
{
    CGContextSetShouldAntialias(context, YES);
    CGContextSetFillColorWithColor(context, self.bubbleBKColor.CGColor ? : DefaultBKColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}
- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;
    CGContextMoveToPoint(context, midx+Arror_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, BubbleRadius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, BubbleRadius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, BubbleRadius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, BubbleRadius);
    CGContextClosePath(context);
}


@end
