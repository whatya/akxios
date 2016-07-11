//
//  Alert.h
//  qingchu
//
//  Created by ZhuXiaoyan on 15/9/16.
//  Copyright (c) 2015年 whtriples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PopUpView.h"
#import "CommonConstants.h"

typedef void (^CompleteAction)();

@interface Alert : NSObject

@property (nonatomic,strong) PopUpView *popView;

+ (Alert *)sharedAlert;

- (void)showMessage:(NSString*)message;

- (void)showMessage:(NSString *)message okTitle:(NSString*)title action:(CompleteAction)block;

@end
