//
//  KeyBordVIew.h
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyBordVIew;

@protocol KeyBordVIewDelegate <NSObject>
-(void)beginRecord;
-(void)finishRecord;
@end

@interface KeyBordVIew : UIView
@property (nonatomic,assign) id<KeyBordVIewDelegate>delegate;
@end