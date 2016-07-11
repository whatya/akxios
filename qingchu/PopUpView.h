//
//  PopUpView.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpView : UIView

@property (weak, nonatomic) IBOutlet UIButton *sureBTN;
@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UILabel *messageLB;
@property (weak, nonatomic) IBOutlet UIView *alphView;

@property(nonatomic, copy) void (^completeBlock)();

@end
