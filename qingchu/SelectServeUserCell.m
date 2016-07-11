//
//  SelectServeUserCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/13.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SelectServeUserCell.h"
#import "CommonConstants.h"
#import "UIImageView+WebCache.h"
#import "ServeCashVC.h"
@implementation SelectServeUserCell
/*
 @property (weak, nonatomic) IBOutlet UIImageView *userImageV;
 @property (weak, nonatomic) IBOutlet UILabel *userName;
 @property (weak, nonatomic) IBOutlet UILabel *surplusNumLB;
 @property (weak, nonatomic) IBOutlet UILabel *serveLB;
 @property (weak, nonatomic) IBOutlet UILabel *rankLB;
 @property (weak, nonatomic) IBOutlet UIButton *selectBtn;
 
 */



- (IBAction)selectBtn:(UIButton *)sender {
    
    
    if ([self.delegate respondsToSelector:@selector(choseButton:)]) {
        
        sender.tag = self.tag;
        
//        [self.delegate choseButton:sender];
    }
    NSLog(@"1111");
}


- (void)configUI:(ServeUserModel *)model withTag:(NSInteger)tag{

    self.buttonTag = 100 + tag;
    [_userImageV sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"itemDefault"]];
   
    _userName.text = model.realname;
    _surplusNumLB.text = [NSString stringWithFormat:@"剩余可服务人数%d人",100-model.currentUsers];
   
    if (model.major == 1) {
        
        _serveLB.text = @"全科";
    }
    if (model.major == 2) {
        
        _serveLB.text = @"心脑血管";
    }
    if (model.major == 3) {
        
        _serveLB.text = @"糖尿病";
    }
    
    if (model.userType == 2) {
        
        _rankLB.text = @"医生";
    }
    if (model.userType == 3) {
        
        _rankLB.text = @"健康管理师";
    }
    
}

- (void)awakeFromNib {
    
    [self.selectBtn addTarget:self action:@selector(toPayForServer) forControlEvents:UIControlEventTouchUpInside];
    
//    self.userImageV.layer.cornerRadius = 40;
//    self.userImageV.layer.masksToBounds = YES;
}
-(void)toPayForServer{
    
    [self.delegate choseButton:self.buttonTag];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
