//
//  KeyBordVIew.m
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import "KeyBordVIew.h"
#import "ChartMessage.h"
#import "ChartCellFrame.h"
#import "UIImage+StrethImage.h"

@interface KeyBordVIew()<UITextFieldDelegate>
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIButton *speakBtn;
@end

@implementation KeyBordVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialData];
    }
    return self;
}

-(UIButton *)buttonWith:(NSString *)noraml hightLight:(NSString *)hightLight action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:noraml] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void)initialData
{
    self.backImageView=[[UIImageView alloc]initWithFrame:self.bounds];
    self.backImageView.image=[UIImage strethImageWith:@"toolbar_bottom_bar.png"];
    [self addSubview:self.backImageView];
    
    self.speakBtn=[self buttonWith:nil hightLight:nil action:@selector(speakBtnPress:)];
    [self.speakBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.speakBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.speakBtn setTitleColor:[UIColor redColor] forState:(UIControlState)UIControlEventTouchDown];
    [self.speakBtn setBackgroundColor:[UIColor whiteColor]];
    [self.speakBtn setFrame:CGRectMake(0, 0, 250, self.frame.size.height*0.8)];
    [self.speakBtn setCenter:CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5)];
    [self addSubview:self.speakBtn];
}
-(void)touchDown:(UIButton *)voice
{
    //开始录音
    
    if([self.delegate respondsToSelector:@selector(beginRecord)]){
    
        [self.delegate beginRecord];
    }
    NSLog(@"开始录音");
}
-(void)speakBtnPress:(UIButton *)voice
{
   //结束录音
    
    if([self.delegate respondsToSelector:@selector(finishRecord)]){
    
        [self.delegate finishRecord];
    }
    NSLog(@"结束录音");
}

@end
