//
//  InputPanle.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/8/17.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^PanleAction)();

@interface InputPanle : UIView

@property(copy) PanleAction okBtnClickedAction;
@property(copy) PanleAction dismisKeyboardAction;

@end
