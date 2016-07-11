//
//  SelectUserCell.m
//  qingchu
//
//  Created by ZhuXiaoyan on 16/5/12.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import "SelectUserCell.h"

#import "UIImageView+WebCache.h"

@implementation SelectUserCell

- (void)awakeFromNib {
    
    self.userImageV.clipsToBounds = YES;
    self.userImageV.layer.cornerRadius = 31.5;
    //self.statusImageV.hidden = YES;
}


- (void)setModel:(SelectUser *)model{

    _model = model;
    
    self.itemLB.text = model.users.imei;
    
    NSString *detailStr = [NSString stringWithFormat:@"%@ %@ %@",model.users.name,model.users.relative,model.users.sex];
    self.nameLB.text = detailStr;
    
    [self.userImageV sd_setImageWithURL:[NSURL URLWithString:model.users.image] placeholderImage:[UIImage imageNamed:@"cellUserAvatar"]];
    
    
//    if (self.selectBtn.selected == YES) {
//        
//        _statusImageV.image = [UIImage imageNamed:@"register-radiobutton-d"];
//    }
//    else{
//    
//        _statusImageV.image = [UIImage imageNamed:@"register-radiobutton-u"];
//    
//    }
 
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
