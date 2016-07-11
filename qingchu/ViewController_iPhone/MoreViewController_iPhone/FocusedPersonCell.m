//
//  FocusedPersonCell.m
//  SlideCellDemo
//
//  Created by ZhuXiaoyan on 15/8/11.
//  Copyright (c) 2015年 ZhuXiaoyan. All rights reserved.
//

#import "FocusedPersonCell.h"
#import "UIImageView+WebCache.h"

@implementation FocusedPersonCell

- (void)awakeFromNib {
    self.roundView.clipsToBounds = YES;
    self.roundView.layer.cornerRadius = 10;
    self.roundView.layer.borderColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.7].CGColor;
    self.roundView.layer.borderWidth = 1.0;
    
    self.personIcon.clipsToBounds = YES;
    self.personIcon.layer.cornerRadius = 30;
    
    self.scrollView.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
    [self.leftView addGestureRecognizer:tap];
}

- (void)setModel:(FocusPersonModel *)model
{
    _model = model;
    NSLog(@"%@",model.user.isMaster ? @"是第一个绑定" : @"不是第一个绑定");
    self.updateContainerView.hidden = !model.user.isMaster;
    self.ime.text = model.user.imei;
    NSString *detailString = [NSString stringWithFormat:@"%@ %@ %@",model.user.name,model.user.relative,model.user.sex];
    self.detailLB.text = detailString;
    
    [self.personIcon sd_setImageWithURL:[NSURL URLWithString:model.user.image] placeholderImage:[UIImage imageNamed:@"cellUserAvatar"]];
    
    if (self.model.opened) {
        [self.scrollView setContentOffset:CGPointMake(self.roundView.bounds.size.width, 0)];
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *focusdImei = [userDefaults objectForKey:@"focusedPersionImei"];
    if (focusdImei) {
        if ([focusdImei isEqualToString:model.user.imei]) {
            self.markImageView.hidden = NO;
        }else{
            self.markImageView.hidden = YES;
        }
    }
}

- (void)showDetail:(UITapGestureRecognizer*)tap
{
    [self.delegate selecteCellWithModel:self.model];
}

- (IBAction)takeAction:(UIButton *)sender
{
    [self.delegate takeActionWithCode:sender.tag withModel:self.model];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        self.model.opened = NO;
    }else{
        self.model.opened = YES;
    }
}

- (IBAction)toggleOpen:(UIButton *)sender
{
    CGFloat screenWidth = self.roundView.bounds.size.width;
    if (self.model.opened) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
        
    }
    self.model.opened = !self.model.opened;
}

@end
