//
//  SkillCell.h
//  qingchu
//
//  Created by 张宝 on 16/5/25.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkillCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pointLB;
@property (weak, nonatomic) IBOutlet UIView *continerView;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *noteLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLB;


@end
