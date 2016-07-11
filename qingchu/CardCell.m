//
//  CardCell.m
//  Demo
//
//  Created by ZhuXiaoyan on 16/3/9.
//  Copyright © 2016年 Nelson. All rights reserved.
//

#import "CardCell.h"
#import "CommonConstants.h"

@implementation CardCell

- (void)awakeFromNib
{
    CALayer *layer = [self layer];
    //self.clipsToBounds = NO;
    layer.cornerRadius = 2;
    //layer.shadowRadius = radius;
    layer.borderWidth = 0;
    //layer.borderColor = [UIColor blackColor].CGColor;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.2;
    layer.shadowOffset = CGSizeMake(0, 0);
    
//    UIColor *imageBorderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];;
//    
//    AddCornerBorder(self.imageView, 0, 0.5, imageBorderColor.CGColor)
}

@end
