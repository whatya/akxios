//
//  UIViewController+DataValidation.m
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import "UIViewController+DataValidation.h"

@implementation UIViewController (DataValidation)

- (BOOL)isValidPhone:(NSString*)phone
{
    if (phone.length == 11) {
        if ([self isPureInt:phone]) {
            if ([phone hasPrefix:@"13"] ||
                [phone hasPrefix:@"14"] ||
                [phone hasPrefix:@"15"] ||
                [phone hasPrefix:@"17"] ||
                [phone hasPrefix:@"18"]) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;

    
//    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
//    
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    BOOL isMatch = [pred evaluateWithObject:phone];
//    
//    return  isMatch;
}

- (BOOL)isValidPassword:(NSString*)password
{
    if (password.length >= 6
        && password.length <= 16
        && [password rangeOfString:@" "].location == NSNotFound)
    {
        return YES;
    }
    return NO;
}


- (BOOL)isPureInt:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}


- (void)shakeAnimationForView:(UIView *) view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:.06];
    [animation setRepeatCount:3];
    [viewLayer addAnimation:animation forKey:nil];
}
@end
