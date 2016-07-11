//
//  UIViewController+DataValidation.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/18.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DataValidation)

- (BOOL)isValidPhone:(NSString*)phone;
- (BOOL)isValidPassword:(NSString*)password;
- (void)shakeAnimationForView:(UIView *) view;

@end
